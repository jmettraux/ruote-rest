
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Fri May 30 21:13:22 JST 2008
#

require 'rubygems'

require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'
require 'testbase'


class StErrorsTest < Test::Unit::TestCase

  include TestBase

  include Sinatra::Builder
  include Sinatra::RenderingHelpers


  def test_0

    get_it "/errors"

    #p @response

    assert_equal(
      "application/xml",
      @response.content_type)

    assert_equal(
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors count=\"0\">\n</errors>\n",
      @response.body)
  end

  def test_0

    fei = $engine.launch <<-EOS
<process-definition name="st_errors" revision="t1">
  <participant ref="tonto" />
</process-definition>
    EOS

    sleep 0.350

    get_it "/errors"

    assert_not_nil @response.body.index(
      "<errors count=\"1\">")
    assert_not_nil @response.body.index(
      "<text>exception : No participant named 'tonto'</text>")
  end
end
