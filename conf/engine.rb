
require 'openwfe/engine'
require 'openwfe/engine/file_persisted_engine'
require 'openwfe/storage/yamlcustom'
require 'openwfe/util/xml'

#require 'openwfe/extras/engine/db_persisted_engine'


#configure do

#ev = Sinatra.application.options.env
ev = 'test'

FileUtils.mkdir 'logs' unless File.exist?('logs')

ac = {}

ac[:engine_name] = "ruote_rest"

ac[:work_directory] = "work_#{ev}"

ac[:logger] = Logger.new "logs/openwferu_#{ev}.log", 10, 1024000
ac[:logger].level = (ev == 'production') ? Logger::INFO : Logger::DEBUG

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

$engine = engine_class.new ac
#end

