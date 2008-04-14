
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Apr 14 17:02:31 JST 2008
#

require 'test/unit'

require 'rubygems'
require 'rack'
require 'misc'


class MiscTest < Test::Unit::TestCase

    def test_0

        assert_equal "0.0.1", swapdots("0_0_1")
        assert_equal "0_0_1", swapdots("0.0.1")
        assert_equal "nada", swapdots("nada")
    end
end
