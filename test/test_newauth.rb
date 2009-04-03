require 'rubygems'
require 'rest_client'
require 'test/unit'
require '../conf/password.rb'


class RuoteTest < Test::Unit::TestCase
include Password
 
  Url = "http://192.168.168.128:4567"
 
  def test_001
 
     site = RestClient::Resource.new Url, { :user => 'charly', :password => 'secret', :headers => {:accept => "text/json"}}
     response = site['workitems'].get
     assert_equal 200, response.code

  end
    

  def test_002
  
    site = RestClient::Resource.new Url, { :user => 'mary', :password => 'secret', :headers => {:accept => "text/json"}}
    begin
      site['workitems'].get 
    rescue Exception => ex
      assert_equal "Unauthorized", ex.message 
    end 

  end

  def test_003

  password = 'stupidsecret'

  assert check_password generate_ssha(password), password
  end

  def test_004

  password = 'stupidpassword'
  
  assert check_password generate_smd5(password), password
  end

  
  # TODO: tests for ToD filter and IP whitelisting
  
end
