
require 'vendorf/frozen' if File.exist?('vendorf/frozen.rb')

namespace :mysql do

  desc "Sets up a mysql database for ruote-rest"
  task :setup do

    #
    # created on a Shinkansen train ride to Tokyo (Nozomi)
    # (just before Shinagawa)
    #

    stage = ENV['stage']

    stage = 'development' \
      unless [ 'test', 'development', 'production' ].include?(stage)

    db = "ruoterest_#{stage}"
    db_admin = ENV['dbadmin'] || 'root'
    #db_user = 'densha'

    puts " .. db is '#{db}'"

    # drop & create

    sh "mysql -u #{db_admin} -p -e \"drop database if exists #{db}\""
    sh "mysql -u #{db_admin} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""

    #sh "mysql -u #{db_admin} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

    # run the migrations

    #gem 'activerecord'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      :adapter => 'mysql',
      :database => db,
      #:username => 'toto',
      #:password => 'secret',
      #:host => 'localhost',
      #:socket => '/var/run/mysqld/mysqld.sock',
      :encoding => 'utf8')

    $:.unshift RUOTE_LIB
    $:.unshift VENDOR_LIB

    require 'openwfe/extras/participants/ar_participants'
    OpenWFE::Extras::ArWorkitemTables.up

    require 'openwfe/extras/expool/db_history'
    OpenWFE::Extras::HistoryTables.up

    #require 'vendor/openwfe/extras/expool/db_errorjournal'
    #OpenWFE::Extras::ProcessErrorTables.up

    #require 'vendor/openwfe/extras/expool/db_expstorage'
    #OpenWFE::Extras::ExpressionTables.up
  end

end

