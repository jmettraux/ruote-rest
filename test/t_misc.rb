
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Apr 14 17:02:31 JST 2008
#

require 'test/unit'

require 'rubygems'
require 'activesupport' # force using activesupport instead of json
require 'rack'

require File.dirname(__FILE__) + '/testbase'
require 'misc'


class MiscTest < Test::Unit::TestCase

  def test_0

    a = [ 1, 2, 3 ]

    # This feels redundent now since the hacks aren't loaded anymore
    assert_equal a, json_parse(OpenWFE::Json.encode(a))
  end
end
