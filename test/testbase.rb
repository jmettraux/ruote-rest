
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 21:59:47 JST 2008
#

require 'test/unit'
require 'fileutils'
require 'ostruct'

require 'rubygems'


RUOTE_BASE_DIR = File.expand_path(File.dirname(File.dirname(__FILE__)))

FileUtils.rm_f(File.dirname(__FILE__) + '/../conf/participants_test.yaml')
  # making sure that this test file gets removed before ruote_rest is required

require File.dirname(__FILE__) + '/test_paths'
require 'ruote_rest'


module TestBase

  class TestParticipant

    attr_reader :params

    def initialize (p1, p2, p3)
      @params = [ p1, p2, p3 ]
    end
  end

  def setup

    FileUtils.rm_rf 'work_test'
    FileUtils.mkdir 'logs' unless File.exist?('logs')

    #
    # prepare rack app

    RuoteRest.build_rack_app(
      Rack::File.new(File.join(RUOTE_BASE_DIR, 'public')),
      :environment => 'test')

    #
    # clean db

    OpenWFE::Extras::ArWorkitem.delete_all
    OpenWFE::Extras::HistoryEntry.delete_all

    #
    # resetting the participant file

    File.open 'conf/participants_test.yaml', 'w' do |f|
      f.puts(YAML.dump([
        [ 'alpha', 'OpenWFE::Extras::ArParticipant', nil ],
        [ 'bravo', 'OpenWFE::Extras::ArParticipant', nil ],
        [ 'carlito', 'TestBase::TestParticipant', [ 'one', 'two', 'three' ] ]
      ]))
    end

    #
    # initting the participant

    RuoteRest.engine.get_participant_map.participants.clear

    Participants.init_all(RuoteRest.engine, 'conf/participants_test.yaml')
  end

  #def teardown
  #  FileUtils.rm "conf/participants_test.yaml"
  #end

  %w{ post get put delete }.each do |v|
    module_eval <<-EOS
      def #{v} (path, body=nil, options={})
        options[:input] = body if body
        @response = Rack::MockRequest.new(RuoteRest.app).request(
          '#{v}'.upcase, path, options)
        # returns @response
      end
    EOS
  end
end

