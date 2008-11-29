
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 21:59:47 JST 2008
#

require 'test/unit'

RUOTE_BASE_DIR = File.expand_path( File.dirname( File.dirname(__FILE__) ) )


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

    OpenWFE::Extras::Workitem.delete_all
    OpenWFE::Extras::Field.delete_all
    OpenWFE::Extras::HistoryEntry.delete_all

    #
    # resetting the participant file

    FileUtils.rm "conf/participants_test.yaml"

    File.open "conf/participants_test.yaml", "w" do |f|
      f.puts(YAML.dump([
        [ 'alpha', 'OpenWFE::Extras::ActiveParticipant', nil ],
        [ 'bravo', 'OpenWFE::Extras::ActiveParticipant', nil ],
        [ 'carlito', 'TestBase::TestParticipant', [ 'one', 'two', 'three' ] ]
      ]))
    end

    #
    # initting the participant

    $app.engine.get_participant_map.participants.clear

    Participants.init_all($app.engine, 'conf/participants_test.yaml')
  end

  #def teardown
  #  FileUtils.rm "conf/participants_test.yaml"
  #end

  [ :post, :get, :put, :delete ].each do |v|
    module_eval <<-EOS
      def #{v} (path, body=nil, options={})
        options[:input] = body if body
        @response = \
          Rack::MockRequest.new($app).request('#{v}'.upcase, path, options)
        @response
      end
    EOS
  end
end
