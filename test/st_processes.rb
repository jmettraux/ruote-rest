
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Sun Apr 13 14:44:10 JST 2008
#

require File.dirname(__FILE__) + '/testbase'


class StProcessesTest < Test::Unit::TestCase

  include TestBase


  def test_0

    get '/processes'

    #p @response
    #puts @response.body

    assert_equal(
      'application/xml',
      @response.content_type)

    #assert_equal(
    #  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<processes count=\"0\" href=\"http://example.org/processes\">\n</processes>\n",
    #  @response.body)
    assert_match(/count="0"/,  @response.body)
  end

  def test_1

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStProcesses1 < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    EOS
    #li.attributes.merge!(
    #  "customer" => "toto", "amount" => 5, "discount" => false )
    #puts
    #puts OpenWFE::Xml.launchitem_to_xml(li, :indent => 2)
    #puts

    post(
      '/processes',
      OpenWFE::Xml.launchitem_to_xml(li, :indent => 2),
      { 'CONTENT_TYPE' => 'application/xml' })

    #puts @response.body

    fei = OpenWFE::Xml.fei_from_xml @response.body

    assert_equal 201, @response.status
    assert_equal 'TestStProcesses', fei.workflow_definition_name
    assert_not_nil @response['Location']

    sleep 0.350

    get '/processes'

    #puts @response.body

    assert_not_nil @response.body.index(fei.wfid)

    get "/processes/#{fei.wfid}"
    #puts
    #puts @response.body
    #puts

    assert_not_nil @response.body.index("<wfid>#{fei.wfid}</wfid>")

    get "/processes/#{fei.wfid}/representation.json"

    #puts @response.body
    js = json_parse(@response.body)
    assert_kind_of Array, js
    assert_equal 'application/json', @response['Content-Type']

    delete "/processes/#{fei.wfid}"

    assert_equal 200, @response.status

    sleep 0.350

    get '/processes'

    assert_not_nil @response.body.index('count="0"')

    get "/processes/#{fei.wfid}"

    assert_equal 404, @response.status
  end

  #
  # pause / resume
  #
  def test_2

    assert_equal 0, OpenWFE::Extras::ArWorkitem.find(:all).size
      #
      # this fixes an AR 2.2.2 issue, grumpf...

    #$app.engine.register_participant :alpha, OpenWFE::HashParticipant

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStProcesses2 < OpenWFE::ProcessDefinition
        alpha
      end
    EOS

    post(
      '/processes',
      OpenWFE::Xml.launchitem_to_xml(li, :indent => 2),
      { 'CONTENT_TYPE' => 'application/xml' })

    fei = OpenWFE::Xml.fei_from_xml @response.body

    sleep 0.350

    put(
      "/processes/#{fei.wfid}",
      '<process><paused>true</paused></process>',
      { 'CONTENT_TYPE' => 'application/xml' })

    assert_not_nil @response.body.index('<paused>true</paused>')

    get "/processes/#{fei.wfid}"

    assert_not_nil @response.body.index('<paused>true</paused>')

    put(
      "/processes/#{fei.wfid}",
      '<process><paused>false</paused></process>',
      { 'CONTENT_TYPE' => 'application/xml' })

    assert_not_nil @response.body.index('<paused>false</paused>')

    $app.engine.cancel_process(fei)

    sleep 0.450

    assert_equal 0, OpenWFE::Extras::ArWorkitem.find(:all).size
  end

  #
  # schedules
  #
  def test_3

    #$app.engine.register_participant :alpha, OpenWFE::HashParticipant

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStProcesses3 < OpenWFE::ProcessDefinition
        _sleep '1h'
      end
    EOS

    post(
      '/processes',
      OpenWFE::Xml.launchitem_to_xml(li, :indent => 2),
      { 'CONTENT_TYPE' => 'application/xml' })

    fei = OpenWFE::Xml.fei_from_xml @response.body

    sleep 0.350

    get "/processes/#{fei.wfid}"

    #puts @response.body
    assert_match(/Rufus::AtJob/, @response.body)
  end

  def test_cancel_process_over_json

    fei = $app.engine.launch(%{
      <process-definition name="test">
        <alpha/>
      </process-definition>
    })

    sleep 0.350

    delete "/processes/#{fei.wfid}.json"

    assert_equal 200, @response.status
  end
end

