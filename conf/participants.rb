
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
    "#{RUOTE_BASE_DIR}/conf/participants_#{application.environment}.yaml")

  #
  # participants loaded, now notify engine it can reschedule
  # time[out] oriented expressions (sleep, when, participant, ...)

  application.engine.reload
  sleep 0.350
    #
    # let the engine reschedule/repause stuff in the expool
end

