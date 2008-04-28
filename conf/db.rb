
gem 'activerecord'
require 'active_record'

configure do

    ActiveRecord::Base.establish_connection(
        :adapter => "mysql",
        :database => "ruote_rest",
        :encoding => "utf8")
end

