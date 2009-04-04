
require 'ar_con'

module RuoteRest

  configure do
    RuoteRest.establish_ar_connection(application.environment)
  end

end

