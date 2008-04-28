
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Apr 14 15:45:00 JST 2008
#



#require 'test/unit'

require 'rubygems'
require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'


class StExpressionsTest < Test::Unit::TestCase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0

        li = OpenWFE::LaunchItem.new <<-EOS
            class TestStExpressions < OpenWFE::ProcessDefinition
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

        sleep 0.350

        get_it "/expressions/#{fei.wfid}"
        #puts
        #puts @response.body
        #puts
        assert_not_nil @response.body.index(' count="5"')


        get_it "/expressions/#{fei.wfid}/0_0"

        assert_not_nil @response.body.index(
            '<class>OpenWFE::SequenceExpression</class>')

        get_it "/expressions/#{fei.wfid}/0e"
        #puts
        #puts @response.body
        #puts
        assert_not_nil(
            @response.body.index('<class>OpenWFE::Environment</class>'), 
            "GET /0e --> not an environment")


        get_it "/expressions/#{fei.wfid}/0"

        assert_not_nil(
            @response.body.index('<class>OpenWFE::DefineExpression</class>'),
            "GET /0e --> not an 'process-definition'")

        #
        # cancel process

        delete_it "/expressions/#{fei.wfid}/0"

        assert_equal 204, @response.status

        sleep 0.350

        # done.
    end

    def test_1

        li = OpenWFE::LaunchItem.new <<-EOS
            class TestStExpressions < OpenWFE::ProcessDefinition
                nada
            end
        EOS

        post_it(
            "/processes", 
            OpenWFE::Xml.launchitem_to_xml(li),
            { "CONTENT_TYPE" => "application/xml" })

        fei = OpenWFE::Xml.fei_from_xml @response.body

        sleep 0.350

        get_it "/expressions/#{fei.wfid}/0_0/yaml"

        assert_equal "text/plain", @response["Content-Type"]

        exp = YAML.load @response.body
        assert_kind_of OpenWFE::FlowExpression, exp

        exp.attributes = { :toto => :surf }

        put_it(
            "/expressions/#{fei.wfid}/0_0",
            exp.to_yaml,
            { "CONTENT_TYPE" => "application/yaml" })

        assert_equal(
            "http://example.org/expressions/#{fei.wfid}/0_0", 
            @response["Location"])

        get_it "/expressions/#{fei.wfid}/0_0/yaml"
        exp = YAML.load @response.body

        assert_equal :surf, exp.attributes[:toto]

        $engine.cancel_process fei

        sleep 0.350
    end
end

