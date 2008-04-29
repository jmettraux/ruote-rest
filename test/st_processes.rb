
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Sun Apr 13 14:44:10 JST 2008
#

require 'rubygems'

require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'
require 'testbase'


class StProcessesTest < Test::Unit::TestCase

    include TestBase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0

        get_it "/processes"

        #p @response

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
        #li.attributes.merge!(
        #    "customer" => "toto", "amount" => 5, "discount" => false )
        #puts
        #puts OpenWFE::Xml.launchitem_to_xml(li, 2)
        #puts

        post_it(
            "/processes", 
            OpenWFE::Xml.launchitem_to_xml(li, 2),
            { "CONTENT_TYPE" => "application/xml" })

        fei = OpenWFE::Xml.fei_from_xml @response.body

        assert_equal 201, @response.status
        assert_equal "TestStProcesses", fei.workflow_definition_name
        assert_not_nil @response["Location"]

        sleep 0.350

        get_it "/processes"

        assert_not_nil @response.body.index(fei.wfid)

        get_it "/processes/#{fei.wfid}"
        #puts
        #puts @response.body
        #puts

        assert_not_nil @response.body.index("<wfid>#{fei.wfid}</wfid>")

        get_it "/processes/#{fei.wfid}/representation"

        js = JSON.parse(@response.body)
        assert_kind_of Array, js
        assert_equal "application/json", @response["Content-Type"]

        delete_it "/processes/#{fei.wfid}"

        assert_equal 204, @response.status

        sleep 0.350

        get_it "/processes"

        assert_not_nil @response.body.index('count="0"')

        get_it "/processes/#{fei.wfid}"

        assert_equal 404, @response.status
    end

    #
    # pause / resume
    #
    def test_2

        $engine.register_participant :alpha, OpenWFE::HashParticipant

        li = OpenWFE::LaunchItem.new <<-EOS
            class TestStProcesses < OpenWFE::ProcessDefinition
                alpha
            end
        EOS

        post_it(
            "/processes", 
            OpenWFE::Xml.launchitem_to_xml(li, 2),
            { "CONTENT_TYPE" => "application/xml" })

        fei = OpenWFE::Xml.fei_from_xml @response.body

        sleep 0.350

        get_it "/processes/#{fei.wfid}"

        put_it(
            "/processes/#{fei.wfid}",
            "<process><paused>true</paused></process>",
            { "CONTENT_TYPE" => "application/xml" })

        assert_not_nil @response.body.index('<paused>true</paused>')

        put_it(
            "/processes/#{fei.wfid}",
            "<process><paused>false</paused></process>",
            { "CONTENT_TYPE" => "application/xml" })

        assert_not_nil @response.body.index('<paused>false</paused>')

        $engine.cancel_process fei

        sleep 0.350
    end
end
