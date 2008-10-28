
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Fri May 30 21:13:22 JST 2008
#

require 'rubygems'

require 'testbase'
require 'ruote_rest.rb'


class StErrorsTest < Test::Unit::TestCase

  include TestBase


  def test_0

    get '/errors'

    #p @response

    assert_equal(
      "application/xml",
      @response.content_type)

    assert_equal(
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors count=\"0\">\n</errors>\n",
      @response.body)

    assert_not_nil @response.headers['ETag']
    assert_nil @response.headers['Last-Modified']
  end

  def test_1

    fei = $app.engine.launch <<-EOS
<process-definition name="st_errors" revision="t1">
  <participant ref="tonto" />
</process-definition>
    EOS

    sleep 0.350

    get '/errors'

    #puts @response.body

    assert_not_nil @response.body.index(
      '<errors count="1">')
    assert_not_nil @response.body.index(
      "<text>No participant named \"tonto\"</text>")

    assert_not_nil @response.headers['ETag']
    assert_not_nil @response.headers['Last-Modified']
  end
end

