
gem 'activerecord'
require 'active_record'

configure do

  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    #:database => "ruoterest_#{Sinatra.application.options.env}",
    :database => "ruoterest_#{application.environment}",
    #:username => 'toto',
    #:password => 'secret',
    :encoding => 'utf8')
end

