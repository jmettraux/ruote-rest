
require 'fileutils'

RUFUSES = %w{ 
    dollar eval lru mnemo scheduler verbs }.collect { |e| "rufus-#{e}" }

#
# do use either :install_workflow_engine either :install_dependency_gems
# but not both
#

#
# Installs under vendor/ the latest source of OpenWFEru (and required 
# subprojects).
#
task :install_workflow_engine do

  FileUtils.mkdir "tmp" unless File.exists?("tmp")

  sh "rm -fR vendor/ruote"
  sh "rm -fR vendor/rufus"
  sh "mkdir vendor"

  RUFUSES.each { |e| git_clone(e) }
  git_clone "ruote"

  sh "sudo gem install -y json_pure"
end

def git_clone (elt)

  sh "cd tmp && git clone git://github.com/jmettraux/#{elt}.git"
  sh "cp -pR tmp/#{elt}/lib/* vendor/"
  sh "rm -fR tmp/#{elt}"
end

#
# install OpenWFEru and its dependencies as gems
#
task :gem_install_workflow_engine do

  GEMS = RUFUSES.dup

  GEMS << "openwferu"
  GEMS << "openwferu-extras"

  GEMS << "json_pure"
  #GEMS << "xml_simple"

  sh "sudo gem install -y #{GEMS.join(' ')}"

  puts
  puts "installed gems  #{GEMS.join(' ')}"
  puts
end

