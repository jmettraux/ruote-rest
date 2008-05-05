
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

        Participants.reset_participants_test_yaml

        $engine.get_participant_map.participants.clear

        Participants.init_all
    end

    #def teardown
    #end
end
