
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


#if Module.constants.include?('Mongrel') then
#  #
#  # graceful shutdown for Mongrel by Torsten Schoenebaum
#  class Mongrel::HttpServer
#    alias :old_graceful_shutdown :graceful_shutdown
#    def graceful_shutdown
#      $app.engine.stop
#      sleep 1
#      old_graceful_shutdown
#    end
#  end
#else
#  at_exit do
#    #
#    # make sure to stop the workflow engine when 'ruote-rest' terminates
#
#    $app.engine.stop
#    sleep 1
#  end
#end

at_exit do
  #
  # make sure to stop the workflow engine when 'ruote-rest' terminates

  $app.engine.stop
  sleep 1
end

Rack::Handler::Mongrel.run b, :Port => 4567

