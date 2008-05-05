
#
# participants initialization goes here

configure do

    #
    # loading active participants

    Participants.init_all

    #
    # other participants

    $engine.register_participant :kilroy do
        puts "Kilroy was here"
    end
end
