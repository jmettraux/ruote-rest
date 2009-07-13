
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Jul 13 08:28:34 JST 2009
#

require File.dirname(__FILE__) + '/testbase'


class FtSubprocessesTest < Test::Unit::TestCase

  include TestBase


  def test_subprocess_access

    li = OpenWFE::LaunchItem.new <<-EOS
      OpenWFE.process_definition :name => 'test' do
        sub0
        process_definition :name => 'sub0' do
          alpha
        end
      end
    EOS

    #p OpenWFE::Xml.launchitem_to_xml(li)

    post(
      "/processes",
      OpenWFE::Xml.launchitem_to_xml(li),
      { "CONTENT_TYPE" => "application/xml" })

    fei = OpenWFE::Xml.fei_from_xml @response.body

    sleep 0.350

    get "/processes"
    assert_not_nil @response.body.index('processes count="1"')

    get "/expressions/#{fei.wfid}"
    assert_not_nil @response.body.index('expressions count="6"')
    assert_not_nil @response.body.index("#{fei.wfid}_0")

    get "/expressions/#{fei.wfid}_0/0_0"
    assert_not_nil @response.body.index('>OpenWFE::ParticipantExpression<')

    get "/workitems/#{fei.wfid}_0/0_0"
    assert_not_nil @response.body.index('<participant_name>alpha<')

    get "/workitems/#{fei.wfid}"
    #puts
    #puts @response.status
    #puts @response.body
    #puts
    assert_not_nil @response.body.index('workitems count="1"')

    put(
      "/workitems/#{fei.wfid}_0/0_0?proceed=proceed",
      @response.body,
      { 'CONTENT_TYPE' => 'application/xml' })


    get "/processes/#{fei.wfid}", nil, { 'HTTP_ACCEPT' => 'text/html' }
    assert_not_nil @response.body.match("GET /expressions/#{fei.wfid}_0/0_0")
  end
end

