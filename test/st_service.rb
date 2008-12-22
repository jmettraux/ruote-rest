
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Sun Apr 13 14:44:10 JST 2008
#

require File.dirname(__FILE__) + '/testbase'


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

    assert_equal 6, a.size
  end
end
