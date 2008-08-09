
#
# participants initialization goes here

configure do

  #
  # other participants

  $engine.register_participant :kilroy do
    puts "Kilroy was here"
  end

  #
  # loading active participants

  Participants.init_all
end
