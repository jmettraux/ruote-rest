
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Sun Apr 13 14:44:10 JST 2008
#

require 'rubygems'

require 'testbase'
require 'ruote_rest.rb'


class StServiceTest < Test::Unit::TestCase

  include TestBase


  def test_0

    get "/service.json"

    #p @response
    #puts @response.body

    assert_equal(
      "application/json",
      @response.content_type)

    a = json_parse(@response.body)

    assert_equal 5, a.size
  end
end
