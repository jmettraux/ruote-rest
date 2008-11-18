
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 18:07:46 JST 2008
#


#require 'test/unit'

require 'rubygems'

require 'testbase'
require 'ruote_rest.rb'


class StWorkitemsTest < Test::Unit::TestCase

  include TestBase


  def test_0

    fei = $app.engine.launch %{
      class Test0 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    }

    sleep 0.200

    assert_equal 1, OpenWFE::Extras::Workitem.find(:all).size

    get '/workitems'

    #p @response.status
    #puts @response.body

    assert_not_nil @response.headers['ETag']
    assert_not_nil @response.headers['Last-Modified']

    workitems = OpenWFE::Xml.workitems_from_xml(@response.body)

    assert_equal 1, workitems.size

    #p workitems.first
    get workitems.first.uri

    #p @response.status
    #puts @response.body
    workitem = OpenWFE::Xml.workitem_from_xml(@response.body)

    assert_equal(workitems.first.uri, workitem.uri)

    #
    # get /workitems?wfid=x

    get "/workitems?wfid=#{fei.wfid}"

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 1, workitems.size

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
      { "CONTENT_TYPE" => "application/xml" })

    get workitem.uri

    workitem = OpenWFE::Xml.workitem_from_xml @response.body

    assert_equal "toto", workitem.owner

    #
    # proceed workitem

    workitem._state = "proceeded"

    put(
      workitem.uri,
      OpenWFE::Xml.workitem_to_xml(workitem),
      { "CONTENT_TYPE" => "application/xml" })

    sleep 0.350

    get workitem.uri

    assert_equal 404, @response.status

    #
    # proceeded ?

    get '/workitems'

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 1, workitems.size
    assert_equal "bravo", workitems.first.participant_name
  end

end

