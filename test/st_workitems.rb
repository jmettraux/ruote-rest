
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 18:07:46 JST 2008
#



#require 'test/unit'

require 'rubygems'
require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'
require 'testbase'


class StWorkitemsTest < Test::Unit::TestCase

  include TestBase

  include Sinatra::Builder
  include Sinatra::RenderingHelpers


  def test_0

    fei = $engine.launch <<-EOS
      class Test0 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    EOS

    sleep 0.200

    assert_equal 1, OpenWFE::Extras::Workitem.find(:all).size

    get_it '/workitems'

    #p @response.status
    #puts @response.body

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 1, workitems.size

    get_it workitems.first._uri

    workitem = OpenWFE::Xml.workitem_from_xml @response.body

    assert_equal workitems.first._uri, workitem._uri

    #
    # get /workitems?wfid=x

    get_it "/workitems?wfid=#{fei.wfid}"

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 1, workitems.size

    get_it "/workitems?wfid=#{fei.wfid}nada"

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 0, workitems.size

    #
    # save workitem

    workitem.owner = "toto"

    put_it(
      workitem._uri,
      OpenWFE::Xml.workitem_to_xml(workitem),
      { "CONTENT_TYPE" => "application/xml" })

    get_it workitem._uri

    workitem = OpenWFE::Xml.workitem_from_xml @response.body

    assert_equal "toto", workitem.owner

    #
    # proceed workitem

    workitem._state = "proceeded"

    put_it(
      workitem._uri,
      OpenWFE::Xml.workitem_to_xml(workitem),
      { "CONTENT_TYPE" => "application/xml" })

    sleep 0.350

    get_it workitem._uri

    assert_equal 404, @response.status

    #
    # proceeded ?

    get_it '/workitems'

    workitems = OpenWFE::Xml.workitems_from_xml @response.body

    assert_equal 1, workitems.size
    assert_equal "bravo", workitems.first.participant_name
  end

end

