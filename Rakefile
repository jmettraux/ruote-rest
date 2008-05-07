
require 'rubygems'

require 'rake'
require 'rake/clean'
#require 'rake/packagetask'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'rake/testtask'


RUOTE_LIB = "~/ruote/lib"
#SINATRA_LIB = "~/sinatra/lib"

#
# tasks

CLEAN.include 'work_test', 'work_development', 'log', 'tmp'

#task :default => [ :clean, :repackage ]


#
# TESTING

#
#     rake test
#
Rake::TestTask.new(:test) do |t|

    t.libs << 'test'
    t.libs << 'conf'
    t.libs << 'vendor'
    t.libs << RUOTE_LIB
    #t.libs << SINATRA_LIB
    t.test_files = FileList['test/test.rb']
    t.verbose = true
end


#
# dumps an initial version of conf/participants_test.yaml
#
task :reset_participants do

    require 'yaml'

    FileUtils.rm "conf/participants_test.yaml"

    File.open "conf/participants_test.yaml", "w" do |f|
        f.puts(YAML.dump([
            [ "alpha", 'OpenWFE::Extras::ActiveParticipant', nil ],
            [ "bravo", 'OpenWFE::Extras::ActiveParticipant', nil ]
        ]))
    end

    puts
    puts "file created ./conf/participants_test.yaml"
    puts
end

#
# other tasks

load 'tasks/install_workflow_engine.rake'
load 'tasks/recreate_mysql_db.rake'

