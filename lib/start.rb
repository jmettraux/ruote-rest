
dir = File.dirname(__FILE__)

$:.unshift "#{dir}"
$:.unshift "#{dir}/../conf"

$:.unshift "#{dir}/../vendor" # if any

#$:.unshift "~/sinatra/lib"
$:.unshift "~/ruote/lib"


require 'rubygems'

load 'ruote_rest.rb'

