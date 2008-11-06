
require 'openwfe/engine'
require 'openwfe/engine/file_persisted_engine'
require 'openwfe/extras/expool/dbhistory'
require 'openwfe/storage/yamlcustom'
require 'openwfe/representations'

#require 'openwfe/extras/engine/db_persisted_engine'


configure do

  FileUtils.mkdir 'logs' unless File.exist?('logs')

  ac = {}

  ac[:engine_name] = "ruote_rest"

  ac[:work_directory] = "work_#{$env}"

  ac[:logger] = Logger.new "logs/openwferu_#{$env}.log", 10, 1024000
  ac[:logger].level = ($env == 'production') ? Logger::INFO : Logger::DEBUG

  ac[:remote_definitions_allowed] = true
    #
    # are [remote] process definitions pointed at via a URL allowed ?

  ac[:definition_in_launchitem_allowed] = true
    #
    # are process definitions embedded in the launchitem allowed ?
    #
    # (this is a dangerous, you really have to trust the clients)

  #
  # instantiating the workflow / BPM engine

  #engine_class = OpenWFE::Engine
    #
    # a transient, in-memory engine

  #engine_class = OpenWFE::FilePersistedEngine
  engine_class = OpenWFE::CachedFilePersistedEngine
    #
    # file based persistence

  #engine_class = OpenWFE::Extras::CachedDbPersistedEngine
    #
    # database persistence for the engine

  engine = engine_class.new ac

  engine.init_service('history', OpenWFE::Extras::DbHistory)
    #
    # tracking history

  engine.reload
  sleep 0.350
    #
    # let the engine reschedule/repause stuff in the expool

  class << application
    attr_reader :engine
  end
  application.instance_variable_set(:@engine, engine)

end
