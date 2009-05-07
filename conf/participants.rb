
#
# participants initialization goes here

module RuoteRest

  configure do

    #
    # other participants

    RuoteRest.engine.register_participant :kilroy do
      puts 'Kilroy was here'
    end

    # a plain error participant for testing purposes
    # (feel free to remove it !)
    #
    RuoteRest.engine.register_participant :houston do
      raise 'Houston, we have a problem'
    end

    #
    # loading active participants

    Participants.init_all(
      RuoteRest.engine,
      "#{RUOTE_BASE_DIR}/conf/participants_#{application.environment}.yaml")

    #
    # participants loaded, now notify engine it can reschedule
    # time[out] oriented expressions (sleep, when, participant, ...)

    RuoteRest.engine.reload
    sleep 0.350
      #
      # let the engine reschedule/repause stuff in the expool
  end

end

