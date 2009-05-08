
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


  # ugly longish test
  #
  def test_launch_view_proceed

    #$OWFE_LOG.level = Logger::DEBUG

    #RuoteRest.engine.get_participant_map.add_observer :all do |channel, args|
    #  p [ :pmap, channel, args.to_s ]
    #end
    #RuoteRest.engine.get_expression_pool.add_observer :all do |channel, args|
    #  p [ :expool, channel, args.to_s ]
    #end

    fei = RuoteRest.engine.launch %{
      class Test0 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    }

    sleep 0.450

    #ps = RuoteRest.engine.process_status(fei)
    #p ps.errors.size
    #p RuoteRest.engine.participants.collect { |r, p| [ r, p.class ] }

    assert_equal 1, OpenWFE::Extras::ArWorkitem.find(:all).size

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

    get "/workitems?wfid=#{fei.wfid}"

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #
    # get /workitems/wfid

    get "/workitems/#{fei.wfid}"

    #puts @response.body

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #
    # non existent process instance's workitems

    get "/workitems?wfid=#{fei.wfid}nada"

    #puts @response.body

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 0, workitems.size

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
    # save workitem

    workitem.owner = 'toto2'

    put(
      workitem.uri,
      workitem.to_h().to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    assert_equal 200, @response.status

    get workitem.uri

    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    assert_equal 'toto2', workitem.owner

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

  # posting a workitem to /workitems
  #
  def test_http_listener

    fei = RuoteRest.engine.launch %{
      class TestHttpListener < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    }

    sleep 0.450

    get "/workitems/#{fei.wfid}/0_0_0"

    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    post(
      "/workitems",
      workitem.to_h().to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    sleep 0.450

    get "/workitems/#{fei.wfid}/0_0_1"

    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    assert_equal 'bravo', workitem.participant_name
  end

end

