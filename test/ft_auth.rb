
#
# Testing ruote-rest's newauth
#
# John Mettraux at OpenWFE dot org
#
# Sat Apr  4 20:05:28 JST 2009
#

require 'rubygems' # for active_record

require 'test/unit'
require File.dirname(__FILE__) + '/test_paths'
require 'ar_con'
require 'auth'


class FtAuthTest < Test::Unit::TestCase

  class AppBehind
    attr_reader :env
    def call (env)
      @env = env
    end
  end

  def setup
    RuoteRest.establish_ar_connection('test')
    @ab = AppBehind.new
  end

  #
  # whitelisting

  def test_whitelisting_out

    env = { 'REMOTE_ADDR' => '18.4.38.61' }

    RuoteRest::RackWhiteListing.new(@ab).call(env)

    assert  ( ! env['RUOTE_AUTHENTICATED'])
  end

  def test_whitelisting_in

    env = { 'REMOTE_ADDR' => '127.0.0.1' }

    RuoteRest::RackWhiteListing.new(@ab).call(env)

    assert env['RUOTE_AUTHENTICATED']
  end

  #
  # basic auth

end

