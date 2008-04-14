
require 'openwfe/engine'
require 'openwfe/util/xml'

configure do

    ac = {}
    ac[:remote_definitions_allowed] = true

    # further configuration goes here

    $engine = OpenWFE::Engine.new ac
end
