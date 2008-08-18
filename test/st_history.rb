
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 18:07:46 JST 2008
#



#require 'test/unit'

require 'rubygems'

require 'testbase'
require 'ruote_rest.rb'


class StHistoryTest < Test::Unit::TestCase

  include TestBase


  def test_0

    fei = $app.engine.launch <<-EOS
      class Test0 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    EOS

    sleep 0.200

    get '/history.json'

    assert_equal 200, @response.status

    a = json_parse(@response.body)

    assert_equal 2, a.size
  end

end

