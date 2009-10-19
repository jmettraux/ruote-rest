
if File.exist?('vendor/frozen.rb')
  require 'vendor/frozen'
elsif File.exist?('vendorf/frozen.rb')
  require 'vendorf/frozen'
end

require 'lib/ar_con'


#
# tasks for setting up mysql
#
namespace :mysql do

  desc 'Sets up a mysql database for ruote-rest'
  task :setup do

    #
    # created on a Shinkansen train ride to Tokyo (Nozomi)
    # (just before Shinagawa)
    #

    stage = determine_stage

    db = "ruoterest_#{stage}"
    db_admin = ENV['dbadmin'] || 'root'
    #db_user = 'densha'

    puts " .. db is '#{db}'"

    # drop & create

    sh "mysql -u #{db_admin} -p -e \"drop database if exists #{db}\""
    sh "mysql -u #{db_admin} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""

    #sh "mysql -u #{db_admin} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

    # run the migrations

    RuoteRest.establish_ar_connection(stage)

    $:.unshift('~/ruote/lib')
    $:.unshift('~/w/ruote/lib')
      # feel free to remove that, core dev only

    require 'openwfe/extras/participants/ar_participants'
    OpenWFE::Extras::ArWorkitemTables.up

    require 'openwfe/extras/expool/db_history'
    OpenWFE::Extras::HistoryTables.up

    $: << File.dirname(__FILE__) + '/../lib'
    require 'models/auth.rb'
    RuoteRest::UserTables.up
    RuoteRest::HostTables.up

    #require 'vendor/openwfe/extras/expool/db_errorjournal'
    #OpenWFE::Extras::ProcessErrorTables.up

    #require 'vendor/openwfe/extras/expool/db_expstorage'
    #OpenWFE::Extras::ExpressionTables.up
  end

  desc 'Populates the authentication data tables'
  task :populate do

    RuoteRest.establish_ar_connection(determine_stage)
    require 'active_record/fixtures'

    fixtures = ENV['fixtures'] ?
      ENV['fixtures'].split(/,/) :
      Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.yml'))

    fixtures.each do |fixture_file|
      Fixtures.create_fixtures(
        'tasks/fixtures', File.basename(fixture_file, '.*'))
    end

    $: << File.dirname(__FILE__) + '/../lib'
    require 'models/auth.rb'

    puts "loaded #{RuoteRest::Host.find(:all).size} hosts"
    puts "loaded #{RuoteRest::User.find(:all).size} users"
  end

  def determine_stage
    stage = ENV['stage']
    stage = 'development' \
      unless %w{ test development production }.include?(stage)
    stage
  end

end

