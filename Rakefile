
require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rake/packagetask'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'rake/testtask'


RUOTE_REST_VERSION = '0.9.19'


RUOTE_LIB = '~/ruote/lib'

#
# tasks

CLEAN.include 'work_test', 'work_development', 'log', 'tmp', 'pkg'

#task :default => [ :clean, :repackage ]


#
# TESTING

#
#   rake test
#
Rake::TestTask.new(:test) do |t|

  ENV['ruote.environment'] = 'test'

  t.libs << 'test'
  t.libs << 'conf'
  t.libs << 'vendor'
  t.libs << RUOTE_LIB
  t.libs << '~/rufus/rufus-sixjo/lib'
  t.test_files = FileList['test/test.rb']
  t.verbose = true
end


#
# other tasks

load 'tasks/ruote.rake'
load 'tasks/mysql.rake'


#
# packaging

#
# source package
#
Rake::PackageTask.new('ruote-rest', RUOTE_REST_VERSION) do |pkg|

  pkg.need_zip = true
  pkg.package_files = FileList[
    'Rakefile',
    '*.txt',
    'conf/**/*',
    'lib/**/*',
    'public/**/*',
    'tools/**/*',
    'tasks/**/*',
    'test/**/*',
    'views/**/*'
  ].to_a
  pkg.package_files.delete('todo.txt')
  class << pkg
    def package_name
      "#{@name}-#{@version}-src"
    end
  end
end

desc "packages a 'distribution' of ruote-rest"
task :distribute do

  pk = "ruote-rest-#{RUOTE_REST_VERSION}"
  dest = "pkg/#{pk}"

  rm_r(dest) if File.exist?(dest)

  mkdir_p dest
  files = %w{
    Rakefile conf lib public tools tasks test views
  }
  %w{ LICENSE CREDITS README CHANGELOG }.each { |t| files << "#{t}.txt" }
  files.each do |src|
    cp_r src, dest
    puts "copied #{src}"
  end

  chdir dest do
    sh 'rake ruote:get_from_github'
  end
  chdir 'pkg' do
    sh "jar cvf #{pk}.zip #{pk}"
  end
end

