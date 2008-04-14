
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Sun Apr 13 14:44:10 JST 2008
#

#require 'test/unit'
require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'


class StProcessesTest < Test::Unit::TestCase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0

        get_it "/processes"

        assert_equal(
            "application/xml", 
            @response.content_type)

        assert_equal(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<processes count=\"0\">\n</processes>\n",
            @response.body)
    end

    def test_1

        li = OpenWFE::LaunchItem.new <<-EOS
            class TestStProcesses < OpenWFE::ProcessDefinition
                sequence do
                    alpha
                    bravo
                end
            end
        EOS

        post_it(
            "/processes", 
            OpenWFE::Xml.launchitem_to_xml(li),
            { "CONTENT_TYPE" => "application/xml" })

        fei = OpenWFE::Xml.fei_from_xml @response.body

        assert_equal 201, @response.status
        assert_equal "TestStProcesses", fei.workflow_definition_name
        assert_not_nil @response["Location"]

        sleep 0.350

        get_it "/processes"

        assert_not_nil @response.body.index(fei.wfid)

        get_it "/processes/#{fei.wfid}"
        #puts @response.body

        assert_not_nil @response.body.index("<wfid>#{fei.wfid}</wfid>")

        delete_it "/processes/#{fei.wfid}"

        assert_equal 204, @response.status

        sleep 0.350

        get_it "/processes"

        assert_not_nil @response.body.index('count="0"')

        get_it "/processes/#{fei.wfid}"

        assert_equal 404, @response.status
    end
end
