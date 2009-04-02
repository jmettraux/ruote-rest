
#
# all the representations on the deck
#
# John Mettraux at OpenWFE dot org
#
# Sun Sep 14 13:02:50 JST 2008
#

require 'rubygems'

require 'testbase'
require 'ruote_rest.rb'


class AllRepsTest < Test::Unit::TestCase

  include TestBase


  def output (rep, label='=')

    puts
    puts "=== #{label} ==="
    rep = rep.gsub(/, /, ",\n ") if label.index('json') or label.index('JSON')
    puts rep
  end

  def output_res (name, opts={})

    opts = { :xml => true, :json => true, :yaml => false }.merge(opts)
    rid = opts.delete(:id)

    [ :xml, :json, :yaml ].each do |ctype|
      next unless opts[ctype]
      url = "/#{name}"
      url = "#{url}/#{rid.join('/')}" if rid
      url = "#{url}.#{ctype}"
      get(url)
      output(@response.body, url)
    end
  end

  def test_0

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStProcesses < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    EOS
    li.attributes.merge!(
      "customer" => "toto", "amount" => 5, "discount" => false )
    #puts
    #puts OpenWFE::Xml.launchitem_to_xml(li, 2)
    #puts

    output OpenWFE::Xml.launchitem_to_xml(li, 2), 'launchitem XML'
    output li.to_h.to_json, 'launchitem JSON'

    post(
      '/processes',
      OpenWFE::Xml.launchitem_to_xml(li, 2),
      { 'CONTENT_TYPE' => 'application/xml' })

    output @response.body, 'FlowExpressionId XML'

    fei = OpenWFE::Xml.fei_from_xml @response.body

    output fei.to_h.to_json, 'FlowExpressionId JSON'

    sleep 0.350

    %w{ processes workitems service }.each do |res_name|
      output_res(res_name)
    end

    #output_res('expressions', :json => false)

    exps = $app.engine.process_status(fei.wfid).all_expressions
    exp = exps.find { |e| e.fei.expname == 'sequence' }

    output_res(
      'expressions',
      :id => [ exp.fei.wfid, OpenWFE.to_uscores(exp.fei.expid)], :json => false, :yaml => true)
  end
end

