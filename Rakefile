
require 'rubygems'

require 'rake'
require 'rake/clean'
#require 'rake/packagetask'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'rake/testtask'

load 'lib/tasks/install_workflow_engine.rake'


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

    t.libs << "test"
    t.libs << "conf"
    t.libs << RUOTE_LIB
    #t.libs << SINATRA_LIB
    t.test_files = FileList['test/test.rb']
    t.verbose = true
end

#
#     rake recreate_mysql_db
#
task :recreate_mysql_db do

    #
    # created on a Shinkansen train ride to Tokyo (Nozomi)
    # (just before Shinagawa)
    #

    stage = ENV['stage']

    stage = 'development' \
        unless [ 'test', 'development', 'production' ].include?(stage)

    db = "ruoterest_#{stage}"
    dbadmin = ENV['dbadmin'] || "root"

    # drop

    begin
        sh 'mysql -u '+dbadmin+' -p -e "drop database '+db+'"'
    rescue Exception => e
    end

    # create

    sh 'mysql -u '+dbadmin+' -p -e "create database '+db+' CHARACTER SET utf8 COLLATE utf8_general_ci"'

    # run the migrations

    gem 'activerecord'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
        :adapter => "mysql",
        :database => db,
        #:username => 'toto',
        #:password => 'secret',
        :encoding => "utf8")
    
    $:.unshift RUOTE_LIB

    require 'openwfe/extras/participants/activeparticipants'
    OpenWFE::Extras::WorkitemTables.up

    #OpenWFE::Extras::ProcessErrorTables.up
    #OpenWFE::Extras::ExpressionTables.up
end

