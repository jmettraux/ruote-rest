
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 18:07:46 JST 2008
#

require File.dirname(__FILE__) + '/testbase'


class StWorkitemsTest < Test::Unit::TestCase

  include TestBase
  
  def setup
    #$OWFE_LOG.level = Logger::DEBUG

    #$app.engine.get_participant_map.add_observer :all do |channel, args|
    #  p [ :pmap, channel, args.to_s ]
    #end
    #$app.engine.get_expression_pool.add_observer :all do |channel, args|
    #  p [ :expool, channel, args.to_s ]
    #end

    @fei = $app.engine.launch %{
      class Test0 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    }

    sleep 0.450
    #sleep 5

    #ps = $app.engine.process_status(@fei)
    #p ps.errors.size
    #p $app.engine.participants.collect { |r, p| [ r, p.class ] }
    
    assert_equal 1, OpenWFE::Extras::Workitem.find(:all).size
  end

  def teardown
    $app.engine.cancel_expression( @fei )
  end

  def get_work_item
    get '/workitems'

    #p @response.status
    #puts @response.body

     workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

     #p workitems.first.uri
    get workitems.first.uri

    #p @response.status
    #puts @response.body
    OpenWFE::Xml.workitem_from_xml(@response.body)
  end

  def test_list_workitems

    get '/workitems'

    #p @response.status
    #puts @response.body

    assert_not_nil @response.headers['ETag']
    assert_not_nil @response.headers['Last-Modified']

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #p workitems.first.uri
    get workitems.first.uri

    #p @response.status
    #puts @response.body
    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    assert_equal(workitems.first.uri, workitem.uri)

    #
    # get /workitems?wfid=x

    get "/workitems?wfid=#{@fei.wfid}"

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #
    # get /workitems/wfid

    get "/workitems/#{@fei.wfid}"

    #puts @response.body

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #
    # non existent process instance's workitems

    get "/workitems?wfid=#{@fei.wfid}nada"

    #puts @response.body

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 0, workitems.size
    
  end

  def test_workitem_updates_from_xml
    workitem = get_work_item
    
    #
    # save workitem

    workitem.owner = 'toto'

    put(
      workitem.uri,
      OpenWFE::Xml.workitem_to_xml(workitem),
      { 'CONTENT_TYPE' => 'application/xml' })

    get workitem.uri

    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    assert_equal 'toto', workitem.owner

    #
    # proceed workitem

    workitem._state = 'proceeded'

    put(
      workitem.uri,
      OpenWFE::Xml.workitem_to_xml(workitem),
      { 'CONTENT_TYPE' => 'application/xml' })

    sleep 0.450

    #p workitem.uri
    get workitem.uri

    #puts @response.body
    assert_equal 404, @response.status

    #sleep 10 # :( activerecord 2.2.2, I hate you

    #
    # proceeded ?

    get '/workitems'

    #puts @response.body
    assert_equal 200, @response.status

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size
    assert_equal 'bravo', workitems.first.participant_name
  end
  
  def test_workitem_updates_from_json
    workitem = get_work_item
    
    #
    # save workitem

    workitem.owner = 'toto'

    put(
      workitem.uri,
      OpenWFE::Json.workitem_to_h(workitem).to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    get "#{workitem.uri}.json"
    
    workitem = OpenWFE::InFlowWorkItem.from_h(OpenWFE::Json.from_json(@response.body))

    assert_equal 'toto', workitem.owner

    #
    # proceed workitem

    workitem._state = 'proceeded'

    put(
      workitem.uri,
      OpenWFE::Json.workitem_to_h(workitem).to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    sleep 0.450

    #p workitem.uri
    get "#{workitem.uri}.json"

    #puts @response.body
    assert_equal 404, @response.status

    #sleep 10 # :( activerecord 2.2.2, I hate you

    #
    # proceeded ?

    get '/workitems'

    #puts @response.body
    assert_equal 200, @response.status

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size
    assert_equal 'bravo', workitems.first.participant_name
  end
end

