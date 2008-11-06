
#
# participants initialization goes here

configure do

  #
  # other participants

  application.engine.register_participant :kilroy do
    puts 'Kilroy was here'
  end

  #
  # loading active participants

  Participants.init_all(
    application.engine,
    "conf/participants_#{application.environment}.yaml")
end

