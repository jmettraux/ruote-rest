
dir = File.dirname(__FILE__)

$:.unshift "#{dir}"
$:.unshift "#{dir}/../conf"

$:.unshift "#{dir}/../vendor" # if any

#$:.unshift "~/sinatra/lib"
$:.unshift "~/ruote/lib"
$:.unshift "~/rufus/rufus-sixjo/lib"


require 'rubygems'

load 'ruote_rest.rb'


b = Rack::Builder.new do

  use Rack::CommonLogger
  use Rack::ShowExceptions
  run $app
end

Rack::Handler::Mongrel.run b, :Port => 4567

