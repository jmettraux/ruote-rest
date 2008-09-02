
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

    #sh "sudo gem install --no-rdoc --no-ri json_pure"
    #sh "sudo gem install --no-rdoc --no-ri json"
    sh "sudo gem install --no-rdoc --no-ri activerecord"
    sh "sudo gem install --no-rdoc --no-ri rogue_parser"
    sh "sudo gem install --no-rdoc --no-ri atom-tools"
  end

  task :get_from_github do

    mkdir 'tmp' unless File.exists?('tmp')

    rm_r 'vendor/ruote'
    rm_r 'vendor/rufus'
    mkdir 'vendor' unless File.exists?('vendor')

    RUFUSES.each { |e| git_clone(e) }
    git_clone 'ruote'
  end

  def git_clone (elt)

    chdir 'tmp' do
      sh "git clone git://github.com/jmettraux/#{elt}.git"
    end
    cp_r "tmp/#{elt}/lib/*", 'vendor/'
    rm_r "tmp/#{elt}"
  end

  desc "Install Ruote and its dependencies as gems"
  task :gem_install do

    GEMS = RUFUSES.dup

    GEMS << 'ruote'
    #GEMS << 'ruote-extras'

    #GEMS << 'json_pure'
    #GEMS << 'json'
    #GEMS << 'rogue_parser'
    GEMS << 'activerecord'
    GEMS << 'atom-tools'

    sh "sudo gem install --no-rdoc --no-ri #{GEMS.join(' ')}"

    #puts
    #puts "installed gems  #{GEMS.join(' ')}"
    #puts
  end
end

