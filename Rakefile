
require 'rubygems'

require 'rake'
require 'rake/clean'
#require 'rake/packagetask'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'rake/testtask'


RUOTE_PATH = "~/ruote/lib"
SINATRA_PATH = "~/sinatra/lib"

#
# tasks

CLEAN.include("work", "log")

#task :default => [ :clean, :repackage ]


#
# TESTING

Rake::TestTask.new(:test) do |t|

    t.libs << "test"
    t.libs << "conf"
    t.libs << RUOTE_PATH
    t.libs << SINATRA_PATH
    t.test_files = FileList['test/test.rb']
    t.verbose = true
end

