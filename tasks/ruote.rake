
#
# tasks for installing / fetching ruote and co
#
# TODO : add doc for each tasks
#
namespace :ruote do

  RUFUSES = %w{ 
    dollar lru mnemo scheduler verbs sixjo treechecker
  }.collect { |e| "rufus-#{e}" }

  #
  # do use either ruote:install or ruote:gem_install
  # but not both
  #

  desc "Installs under vendor/ the latest source of OpenWFEru (and required subprojects)."
  task :install => :get_from_github do

    puts "\n... now installing the gems required by ruote\n"
    print "(sudoing) "
    %w{
      activerecord ruby_parser atom-tools mongrel rack
    }.each do |gem|
      sh "sudo gem install --no-rdoc --no-ri #{gem}"
    end
  end

  task :get_from_github do

    rm_r 'vendor' if File.exists?('vendor')
    mkdir 'vendor' #unless File.exists?('vendor')

    RUFUSES.each { |e| git_clone(e) }
    git_clone 'ruote'

    require File.dirname(__FILE__) + '/frigo'
    Frigo.create_frozen_rb('vendor')

    File.open('vendor/README.txt', 'w') do |f|
      f.write %{
= vendor

This directory contains ruote and its rufus dependencies, directly checked
out of http://github.com

Each subdir contains the .git/ repository, in case you might want to 'git pull'
a new version.

      }
    end
  end

  def git_clone (elt)

    chdir 'vendor' do
      sh "git clone git://github.com/jmettraux/#{elt}.git"
      sh "rm -rf #{elt}/.git"
    end
  end

  desc "Install Ruote and its dependencies as gems"
  task :gem_install do

    GEMS = RUFUSES.merge %w{ ruote activerecord atom-tools rack mongrel }

    sh "sudo gem install --no-rdoc --no-ri #{GEMS.join(' ')}"

    #puts
    #puts "installed gems  #{GEMS.join(' ')}"
    #puts
  end

  desc "Fetches ruote and all its dependencies, then puts the frozen gems under vendorf/"
  task :install_freeze do

    require File.dirname(__FILE__) + '/frigo'

    Frigo.verbose = true

    Frigo.fetch_with_dependencies('activerecord', nil, 'vendorf')
    Frigo.fetch_with_dependencies('rack', nil, 'vendorf')
    Frigo.fetch_with_dependencies('atom-tools', nil, 'vendorf')
    Frigo.fetch_with_dependencies('ruote', nil, 'vendorf')
    Frigo.fetch_with_dependencies('rufus-sixjo', nil, 'vendorf')
  end
end

