
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Fri May 30 21:13:22 JST 2008
#

require File.dirname(__FILE__) + '/testbase'


class StErrorsTest < Test::Unit::TestCase

  include TestBase


  def test_get_empty_errors

    get '/errors'

    #puts @response.body

    assert_equal(
      'application/xml',
      @response.content_type)

    assert_equal(
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors count=\"0\">\n  <link href=\"/\" rel=\"via\"/>\n  <link href=\"/errors\" rel=\"self\"/>\n</errors>\n",
      @response.body)

    assert_not_nil @response.headers['ETag']
    assert_nil @response.headers['Last-Modified']
  end

  def test_get_errors

    fei = RuoteRest.engine.launch <<-EOS
<process-definition name="st_errors" revision="t1">
  <participant ref="tonto" />
</process-definition>
    EOS

    sleep 0.450

    get '/errors'

    #puts @response.body

    assert_not_nil @response.body.index(
      '<errors count="1">')
    assert_not_nil @response.body.match(
      '<message>pexp : no participant named .*tonto.*</message>')

    assert_not_nil @response.headers['ETag']
    assert_not_nil @response.headers['Last-Modified']
  end

  def test_replay_error

    fei = RuoteRest.engine.launch <<-EOS
<process-definition name="st_errors" revision="t1">
  <participant ref="tonto" />
</process-definition>
    EOS

    sleep 1

    get '/errors'

    #puts @response.body
    errors = OpenWFE::Xml.errors_from_xml(@response.body)
    error = errors.first

    e0date = error.date

    delete error.href

    sleep 0.450

    # error re-occured since root cause hasn't been fixed

    get error.href
    error = OpenWFE::Xml.error_from_xml(@response.body)

    assert_not_equal e0date, error.date
  end
end

