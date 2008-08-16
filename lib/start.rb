
dir = File.dirname(__FILE__)

$:.unshift "#{dir}"
$:.unshift "#{dir}/../conf"

$:.unshift "#{dir}/../vendor" # if any

#$:.unshift "~/sinatra/lib"
$:.unshift "~/ruote/lib"
$:.unshift "~/rufus/rufus-sixjo/lib"


require 'rubygems'

load 'ruote_rest.rb'

Rack::Handler::Mongrel.run $app, :Port => 4567

