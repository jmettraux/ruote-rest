
require 'optparse'

dir = File.dirname(__FILE__)

$:.unshift "#{dir}"
$:.unshift "#{dir}/../conf"

$:.unshift "#{dir}/../vendor" # if any

$:.unshift "~/ruote/lib"
$:.unshift "~/rufus/rufus-sixjo/lib"

#
# parse options

port = 4567

opts = OptionParser.new

opts.banner = 'Usage: ruby lib/start.rb [options]'
opts.separator('')
opts.separator('options:')

opts.on('-p', '--port {port}', 'which port to listen to') do |v|
  port = v.to_i
end
opts.on('-e', '--env {env}', 'which env ? development/production') do |v|
  ENV['ruote.environment'] = v
end
opts.on('-h', '--help', 'display this help content') do
  puts
  puts opts.to_s
  puts
  exit 0
end

opts_rest = opts.parse(ARGV)


#
# run ruote-rest

require 'rubygems'

load 'ruote_rest.rb'

b = Rack::Builder.new do

  use Rack::CommonLogger
  use Rack::ShowExceptions
  run $app
end

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

