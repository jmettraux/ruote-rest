
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
require 'testbase'


class StParticipantsTest < Test::Unit::TestCase

    include TestBase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0

        get_it "/participants"

        assert_equal 200, @response.status
        assert_equal "application/xml", @response["Content-Type"]

        post_it(
            "/participants",
            '["toto","OpenWFE::HashParticipant"]',
            { "CONTENT_TYPE" => "application/json" })

        assert_equal 201, @response.status
        assert_not_equal "", @response.body

        get_it "/participants"

        assert_not_nil @response.body.index(' count="3"')

        get_it "/participants/2"

        assert_not_nil @response.body.index('>toto<')

        delete_it "/participants/2"

        assert_equal 204, @response.status

        get_it "/participants"

        assert_not_nil @response.body.index(' count="2"')
    end

    def test_1

        post_it(
            "/participants",
            '["toto","OpenWFE::Extras::ActiveStoreParticipant", "totostore"]',
            { "CONTENT_TYPE" => "application/json" })

        assert_equal 201, @response.status
        assert_not_equal "", @response.body

        get_it "/participants"

        assert_not_nil @response.body.index(' count="3"')

        get_it "/participants?pname=toto"

        assert_equal 200, @response.status
        assert_not_nil @response.body.index('toto')
    end

end

