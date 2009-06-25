
require File.dirname(__FILE__) + '/testbase'


class StExpressionsTest < Test::Unit::TestCase

  include TestBase


  def test_update_and_reget_expression

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStExpressions < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
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


    ## workitem flowexpression yaml update

    get "/expressions/#{fei.wfid}/0_0_0?format=yaml"

    assert_equal 200, @response.status

    exp = YAML.load @response.body
    exp.attributes = { :toto => :surf }

    put(
      "/expressions/#{fei.wfid}/0_0_0",
      exp.to_yaml,
      { 'CONTENT_TYPE' => 'application/yaml' })

    assert_equal 200, @response.status


    ## now, asking for the workitem flowexpression and process flowexpression fails with errors:

    ## "undefined method `ctime' for "2009-06-08 11:07:48.030196 +02:00":String"      ('ACCEPT' => 'application/xml')
    ## "undefined method `httpdate' for "2009-06-08 11:44:04.057000 +02:00":String"   ('ACCEPT' => 'text/html')


    get "/expressions/#{fei.wfid}", nil, {'HTTP_ACCEPT' => 'application/json'}
    assert_equal 200, @response.status

    get "/expressions/#{fei.wfid}", nil, {'HTTP_ACCEPT' => 'application/xml'}
    assert_equal 200, @response.status

    get "/expressions/#{fei.wfid}", nil, {'HTTP_ACCEPT' => 'text/html'}
    assert_equal 200, @response.status
  end

end
