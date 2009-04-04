
#
# Testing ruote-rest's newauth
#
# Gonzalo + Nando
#
# 2009/04/02
#

require 'test/unit'
require File.dirname(__FILE__) + '/test_paths'
require 'password'


class AuthTest < Test::Unit::TestCase
  include RuoteRest::Password

  def test_ssha_hashing

    password = 'stupidsecret'

    assert(check_password(generate_ssha(password), password))
  end

  def test_smd5_hashing

    password = 'stupidpassword'

    assert(check_password(generate_smd5(password), password))
  end

end

