
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

    fei = launch_faulty_process

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

    fei = launch_faulty_process

    get '/errors'

    errors = OpenWFE::Xml.errors_from_xml(@response.body)
    error = errors.first

    fd0 = error.fdate

    delete error.href
    #puts @response.body

    sleep 0.450

    # error re-occured since root cause hasn't been fixed

    get error.href
    error = OpenWFE::Xml.error_from_xml(@response.body)

    assert_not_equal fd0, error.fdate
  end

  def test_replay_error_with_updated_workitem

    fei = launch_faulty_process

    err = get_error(fei.wfid)

    wi = err.workitem
    wi.attributes['kilroy'] = 'was here'

    post(
      "/errors/#{fei.wfid}/0_0",
      wi.to_h().to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    assert_equal 200, @response.status

    sleep 0.450

    err = get_error(fei.wfid)

    assert_equal({ 'kilroy' => 'was here' }, err.workitem.attributes)
  end

  def test_replay_error_with_updated_workitem_attributes

    fei = launch_faulty_process

    err = get_error(fei.wfid)

    post(
      "/errors/#{fei.wfid}/0_0",
      { 'kilroy' => 'was there' }.to_json,
      { 'CONTENT_TYPE' => 'application/json' })

    assert_equal 200, @response.status

    sleep 0.450

    err = get_error(fei.wfid)

    assert_equal({ 'kilroy' => 'was there' }, err.workitem.attributes)
  end

  protected

  def launch_faulty_process

    fei = RuoteRest.engine.launch <<-EOS
<process-definition name="st_errors" revision="t1">
  <participant ref="tonto" />
</process-definition>
    EOS

    sleep 0.450

    fei
  end

  def get_error (wfid)

    get "/errors/#{wfid}/0_0"

    OpenWFE::Xml.error_from_xml(@response.body)
  end
end

