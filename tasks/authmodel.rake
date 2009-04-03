if File.exist?('vendor/frozen.rb')
  require 'vendor/frozen'
elsif File.exist?('vendorf/frozen.rb')
  require 'vendorf/frozen'
end

namespace :authmodel do

    stage = ENV['stage']

    stage = 'development' \
      unless [ 'test', 'development', 'production' ].include?(stage)

    db = "ruoterest_#{stage}"
    db_admin = ENV['dbadmin'] || 'root'
    #db_user = 'densha'


    gem 'activerecord'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      :adapter => 'mysql',
      :database => db,
      :username => 'root',
      :password => '2secure',
      :host => 'localhost',
      #:socket => '/var/run/mysqld/mysqld.sock',
      :encoding => "utf8")

    $:.unshift RUOTE_LIB
    $:.unshift VENDOR_LIB


  desc "Creates tables for new authentication model"
  task :setup do

    #
    # created @ abstra·cc
    # (eating Orio's donuts)
    #

    # drop & create

    sh "mysql -u #{db_admin} -p -e \"drop table if exists #{db}.users\""
    sh "mysql -u #{db_admin} -p -e \"drop table if exists #{db}.hosts\""

    #sh "mysql -u #{db_admin} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""

    #sh "mysql -u #{db_admin} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

    # run the migrations

    #gem 'activerecord'
    require 'active_record'

    require 'conf/auth_models.rb'
    OpenWFE::Extras::UserTables.up
    OpenWFE::Extras::HostTables.up

  end

  desc "Populates the tables for new authentication model"
  task :fixtures do

    require 'active_record/fixtures'

    fixtures = ENV['fixtures'] ? ENV['fixtures'].split(/,/) : Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.yml'))  
    fixtures.each do |fixture_file|  
      Fixtures.create_fixtures('tasks/fixtures', File.basename(fixture_file, '.*'))  
    end 
  end 

end

