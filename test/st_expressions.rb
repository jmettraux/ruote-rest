
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Apr 14 15:45:00 JST 2008
#

#require 'test/unit'
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
        puts
        puts @response.body
        puts

        assert_not_nil @response.body.index(' count="5"')

        get_it "/expressions/#{fei.wfid}/0_0"
        puts
        puts @response.body
        puts
    end
end

