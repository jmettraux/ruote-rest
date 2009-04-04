
#
# Testing ruote-rest's newauth
#
# Gonzalo + Nando
#
# 2009/04/02
#

require File.dirname(__FILE__) + '/testbase'


class AuthTest < Test::Unit::TestCase
  include RuoteRest::Password

  #require 'rest_client'
  #URL = "http://192.168.168.128:4567"
  #def test_authorized_access
  #  site = RestClient::Resource.new(
  #    URL,
  #    { :user => 'charly',
  #      :password => 'secret',
  #      :headers => { :accept => 'text/json' }})
  #  response = site['workitems'].get
  #  assert_equal 200, response.code
  #end
  #def test_unauthorized_access
  #  site = RestClient::Resource.new(
  #    Url,
  #    { :user => 'mary',
  #      :password => 'secret',
  #      :headers => { :accept => 'text/json' }})
  #  begin
  #    site['workitems'].get
  #  rescue Exception => ex
  #    assert_equal 'Unauthorized', ex.message
  #  end
  #end
  #
  # TODO: tests for ToD filter and IP whitelisting

  def test_ssha_hashing

    password = 'stupidsecret'

    assert(check_password(generate_ssha(password), password))
  end

  def test_smd5_hashing

    password = 'stupidpassword'

    assert(check_password(generate_smd5(password), password))
  end

end

