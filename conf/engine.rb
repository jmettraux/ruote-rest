
require 'openwfe/engine'
require 'openwfe/storage/yamlcustom'
require 'openwfe/util/xml'

configure do

    ac = {}

    ac[:remote_definitions_allowed] = true
        #
        # are [remote] process definitions pointed at via a URL allowed ?

    ac[:definition_in_launchitem_allowed] = true
        #
        # are process definitions embedded in the launchitem allowed ?
        #
        # (this is a dangerous, you really have to trust the clients)

    # further configuration goes here

    $engine = OpenWFE::Engine.new ac
    #$engine = OpenWFE::FilePersistedEngine.new ac
end

