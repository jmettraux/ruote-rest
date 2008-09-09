
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

    # drop & create

    sh "mysql -u #{db_admin} -p -e \"drop database if exists #{db}\""
    sh "mysql -u #{db_admin} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""

    #sh "mysql -u #{db_admin} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

    # run the migrations

    gem 'activerecord'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      :adapter => 'mysql',
      :database => db,
      #:username => 'toto',
      #:password => 'secret',
      #:socket => '/var/run/mysqld/mysqld.sock', # on debian
      :encoding => "utf8")

    $:.unshift RUOTE_LIB
    $:.unshift VENDOR_LIB

    require 'openwfe/extras/participants/activeparticipants'
    OpenWFE::Extras::WorkitemTables.up

    require 'openwfe/extras/expool/dbhistory'
    OpenWFE::Extras::HistoryTables.up

    #OpenWFE::Extras::ProcessErrorTables.up
    #OpenWFE::Extras::ExpressionTables.up
  end

end

