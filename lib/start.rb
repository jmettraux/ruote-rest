
dir = File.dirname(__FILE__)

$:.unshift "#{dir}"
$:.unshift "#{dir}/../conf"

$:.unshift "#{dir}/../vendor" # if any

$:.unshift "~/ruote/lib"
$:.unshift "~/rufus/rufus-sixjo/lib"


require 'rubygems'

load 'ruote_rest.rb'


b = Rack::Builder.new do

  use Rack::CommonLogger
  use Rack::ShowExceptions
  run $app
end

port = 4567 # TODO : optparse me

puts ".. [#{Time.now}] ruote-rest listening on port #{port}"

Rack::Handler::Mongrel.run(b, :Port => port) do |server|
  trap(:INT) do
    puts "\n.. [#{Time.now}] stopping webserver and workflow engine ..."
    server.stop
    $rr.engine.stop
    sleep 1
    puts ".. [#{Time.now}] stopped."
  end
end

