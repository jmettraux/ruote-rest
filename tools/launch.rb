
$:.unshift "~/ruote/lib"

require 'rubygems'

require 'optparse'

require 'json'

require 'openwfe/workitem'
require 'openwfe/util/xml'


#
# OPTIONS

json = false
url = nil
launch = false


opts = OptionParser.new

opts.banner = "Usage: ruby #{$0} [options]"
opts.separator("")
opts.separator("options:")

opts.on(
    "-j", "--json", 
    "outputs the launchitem in JSON (default is XML)") do

    json = true
end

opts.on(
    "-x", "--xml", 
    "outputs the launchitem in XML (already the default)") do

    json = false
end

opts.on(
    "-u", "--url {url}", 
    "points to the URL of a process defintion") do |u|

    url = u
end

opts.on(
    "-l", "--launch", 
    "generates the launchitem and use it to launch a process locally") do

    launch = true
end

# help

opts.on("-h", "--help", "display this help content") do
    puts
    puts opts.to_s()
    puts
    exit 0
end

opts_rest = opts.parse(ARGV)


#
# MAIN

li = OpenWFE::LaunchItem.new
li.workflow_definition_url = url
li.attributes.merge!({ 
    'my_field' => 'my_value',
    'my_other_field' => 1234567,
    'yet_another?' => true
})

sli = if json 
    li.to_h.to_json
else
    OpenWFE::Xml.launchitem_to_xml li, 2
end

unless launch
    puts sli
    exit 0
end

# launch

require 'rufus/verbs'

res = Rufus::Verbs::post "http://localhost:4567/processes" do |request|
    request['Content-Type'] = json ? 'application/json' : 'application/xml'
    sli
end

puts res.body

