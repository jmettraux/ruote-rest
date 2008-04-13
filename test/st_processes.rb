
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

require 'application.rb'

class StProcessesTest < Test::Unit::TestCase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0

        get_it "/processes.xml"

        assert_equal(
            "application/xml", 
            @response.content_type)

        assert_equal(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<processes>\n</processes>\n",
            @response.body)
    end

    def test_1

        xml = builder do |x|
            x.instruct!
            x.launchitem do
                x.wfdurl "http://toto.server.com/def"
            end
        end

        post_it "/processes.xml", xml, { "CONTENT_TYPE" => "application/xml;fuck" }

        assert_equal "nada", @response.body
    end
end
