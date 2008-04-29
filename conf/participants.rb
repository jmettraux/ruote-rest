
require 'openwfe/worklist/storeparticipant'
require 'openwfe/extras/participants/activeparticipants'


#
# participants initialization goes here

configure do

    #$engine.register_participant :toto do
    #    puts "hello world"
    #end

    active_participants = [ :alpha, :bravo ]

    active_participants.each do |ap|
        $engine.register_participant ap, OpenWFE::Extras::ActiveParticipant
    end
end

