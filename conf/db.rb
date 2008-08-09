
gem 'activerecord'
require 'active_record'

configure do

  db = "ruoterest_#{Sinatra.application.options.env}"

  ActiveRecord::Base.establish_connection(
    :adapter => "mysql",
    :database => db,
    #:username => 'toto',
    #:password => 'secret',
    :encoding => "utf8")
end

