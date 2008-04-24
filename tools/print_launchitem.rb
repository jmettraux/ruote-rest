
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


opts = OptionParser.new

opts.banner = "Usage: ruby tools/print_launchitem.rb [options]"
opts.separator("")
opts.separator("options:")

opts.on("-j", "--json", "outputs the launchitem in JSON (default is XML)") do
    json = true
end

opts.on("-x", "--xml", "outputs the launchitem in XML (already the default)") do
    json = false
end

opts.on("-u", "--url {url}", "points to the URL of a process defintion") do |u|
    url = u
end

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
li.attributes["my_key"] = "my_value"

if json 
    puts li.to_h.to_json
else
    puts OpenWFE::Xml.launchitem_to_xml(li, 2)
end
