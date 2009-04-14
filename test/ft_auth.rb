
#
# Testing ruote-rest's newauth
#
# John Mettraux at OpenWFE dot org
#
# Sat Apr  4 20:05:28 JST 2009
#

require 'rubygems' # for active_record

require 'test/unit'
require 'base64'
require 'rack/builder'

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

    assert_equal false, env[:ruote_authenticated]
  end

  def test_whitelisting_in

    env = { 'REMOTE_ADDR' => '127.0.0.1' }

    RuoteRest::RackWhiteListing.new(@ab).call(env)

    assert env[:ruote_authenticated]
  end

  #
  # basic auth

  def test_basicauth_out

    env = {}

    res = RuoteRest::RackBasicAuth.new(
      @ab,
      :realm => 'test-realm',
      :blocking => true
    ).call(env)

    assert_equal(
      [ 401, { 'WWW-Authenticate' => 'Basic realm="test-realm"' }, [] ], res)
  end

  def test_basicauth_wrong_pass

    env = { 'HTTP_AUTHORIZATION' => basic('toto', 'nada') }

    res = RuoteRest::RackBasicAuth.new(
      @ab,
      :realm => 'test-realm',
      :blocking => true
    ).call(env)

    assert_equal(
      [ 401, { 'WWW-Authenticate'=>'Basic realm="test-realm"' }, [] ], res)
  end

  def test_basicauth_in_alice

    env = { 'HTTP_AUTHORIZATION' => basic('alice', 'secret') }

    res = RuoteRest::RackBasicAuth.new(@ab, :realm => 'test-realm').call(env)

    assert_equal('alice', env['REMOTE_USER'])
    assert_equal(true, env[:ruote_authenticated])
  end

  def test_basicauth_in_bob

    # Bob uses a different hash algo than Alice

    env = { 'HTTP_AUTHORIZATION' => basic('bob', 'secret') }

    res = RuoteRest::RackBasicAuth.new(@ab, :realm => 'test-realm').call(env)

    assert_equal('bob', env['REMOTE_USER'])
    assert_equal(true, env[:ruote_authenticated])
  end

  def test_chainedauth__whitelist_out

    env = { 'REMOTE_ADDR' => '18.4.38.61' }

    res = build_classic_auth_chain.call(env)

    assert_equal(
      [ 401, {}, 'get off !' ], res)
  end

  def test_chainedauth__whitelist_in__bauth_out

    env = { 'REMOTE_ADDR' => '192.168.168.1' }

    res = build_classic_auth_chain.call(env)

    assert_equal(
      [ 401, { 'WWW-Authenticate'=>'Basic realm="test-realm"' }, [] ], res)
  end

  def test_chainedauth__whitelist_in

    env = { 'REMOTE_ADDR' => '127.0.0.1' }

    res = build_classic_auth_chain.call(env)

    assert_equal(true, env[:ruote_authenticated])
  end

  def test_chainedauth__whitelist_in__bauth_in

    env = {
      'REMOTE_ADDR' => '192.168.168.1',
      'HTTP_AUTHORIZATION' => basic('bob', 'secret') }

    res = build_classic_auth_chain.call(env)

    assert_equal(true, env[:ruote_authenticated])
  end

  protected

  def basic (u, p)
    "Basic " + Base64.encode64("#{u}:#{p}").strip
  end

  def build_classic_auth_chain

    ab = @ab
      # closure...

    Rack::Builder.new do
      use(RuoteRest::RackWhiteListing)
      use(RuoteRest::RackBasicAuth, :realm => 'test-realm')
      run ab
    end
  end

end

