
require 'active_record'

module RuoteRest

  configure do

    configuration = YAML.load_file(
      File.join(RUOTE_BASE_DIR, 'conf', 'database.yaml')
    )[application.environment]

    raise(ArgumentError.new(
      "No database configuration for #{application.environment} environment!")
    ) if configuration.nil?

    ActiveRecord::Base.establish_connection(
      :adapter => configuration['adapter'],
      :database => configuration['database'],
      :username => configuration['username'],
      :password => configuration['password'],
      :host => configuration['host'],
      :encoding => configuration['encoding'],
      :pool => 30
    )
  end

end

