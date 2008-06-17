
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 21:59:47 JST 2008
#

module TestBase

  def setup

    FileUtils.rm_rf 'work_test'
    FileUtils.mkdir 'logs' unless File.exist?('logs')

    OpenWFE::Extras::Workitem.delete_all
    OpenWFE::Extras::Field.delete_all

    #
    # resetting the participant file

    FileUtils.rm "conf/participants_test.yaml"

    File.open "conf/participants_test.yaml", "w" do |f|
      f.puts(YAML.dump([
        [ "alpha", 'OpenWFE::Extras::ActiveParticipant', nil ],
        [ "bravo", 'OpenWFE::Extras::ActiveParticipant', nil ]
      ]))
    end

    #
    # initting the participant

    $engine.get_participant_map.participants.clear

    Participants.init_all
  end

  #def teardown
  #end
end
