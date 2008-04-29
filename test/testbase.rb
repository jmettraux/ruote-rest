
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 21:59:47 JST 2008
#

module TestBase

    def setup

        FileUtils.rm_rf "work_test" 

        OpenWFE::Extras::Workitem.delete_all
        OpenWFE::Extras::Field.delete_all
    end

    #def teardown
    #end
end
