
require 'optparse'

#
# parse options

port = 4567
daemonize = false
pid = nil
basic_auth_realm = 'ruote-rest'

opts = OptionParser.new

opts.banner = 'Usage: ruby lib/start.rb [options]'
opts.separator('')
opts.separator('options:')

opts.on('-p', '--port {port}', 'which port to listen to') do |v|
  port = v.to_i
end
opts.on('-e', '--env {env}', 'which env ? development/production') do |v|
  ENV['ruote.environment'] = v
end
opts.on('-d', '--daemonize', 'run daemonized in the background') do |d|
  daemonize = d ? true : false
end
opts.on('-P', '--pid [FILE]', 'file to store PID (default: ruote-rest.pid)') do |f|
  pid = File.expand_path( f || 'ruote-rest.pid' )
end
opts.on('-r', '--realm {realm}', 'basic authentication realm name') do |r|
  basic_auth_realm = r
end
opts.on('-h', '--help', 'display this help content') do
  puts
  puts opts.to_s
  puts
  exit 0
end

opts.parse!(ARGV)

# Our base directory
RUOTE_BASE_DIR = File.expand_path( File.dirname( File.dirname(__FILE__) ) )

if daemonize
  if RUBY_VERSION < '1.9'
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir '/'
    File.umask 0000
    STDIN.reopen '/dev/null'
    STDOUT.reopen '/dev/null', 'a'
    STDERR.reopen '/dev/null', 'a'
  else
    Process.daemon
  end

  if pid
    File.open(pid, 'w'){ |f| f.write(Process.pid.to_s) }
    at_exit { File.delete(pid) if File.exist?(pid) }
  end
end

begin

  if File.exist?("#{RUOTE_BASE_DIR}/vendor/frozen.rb")
    require "#{RUOTE_BASE_DIR}/vendor/frozen"
  elsif File.exist?("#{RUOTE_BASE_DIR}/vendorf/frozen.rb")
    require "#{RUOTE_BASE_DIR}/vendorf/frozen"
  end

  $:.unshift "#{RUOTE_BASE_DIR}/lib"
  $:.unshift "#{RUOTE_BASE_DIR}/conf"

  $:.unshift '~/ruote/lib'
  $:.unshift '~/w/ruote/lib'
  $:.unshift '~/rufus/rufus-sixjo/lib'
  $:.unshift '~/w/rufus/rufus-sixjo/lib'
    #
    # feel free to nuke those two lines (dev only !)

  #
  # run ruote-rest

  require 'rubygems'

  #load File.join(RUOTE_BASE_DIR, 'lib', 'ruote_rest.rb')
  require 'ruote_rest'

  b = Rack::Builder.new do

    use Rack::CommonLogger
    use Rack::ShowExceptions

    use RuoteRest::RackWhiteListing
    use RuoteRest::RackBasicAuth, :realm => basic_auth_realm

    run RuoteRest.build_rack_app(
      Rack::File.new(File.join(RUOTE_BASE_DIR, 'public')),
      :environment => $env)
  end

  puts ".. [#{Time.now}] ruote-rest listening on port #{port}"

  Rack::Handler::Mongrel.run(b, :Port => port) do |server|
    trap(:INT) do
      puts "\n.. [#{Time.now}] stopping webserver and workflow engine ..."
      server.stop
      RuoteRest.engine.stop
      sleep 1
      puts ".. [#{Time.now}] stopped."
    end
  end

rescue => e

  # Throw the exception back out again if we're not daemonized
  raise e unless daemonize

  # Write our backtrace

  filename = File.join(
    RUOTE_BASE_DIR, "backtrace-#{Time.now.strftime('%Y%m%d%H%M%S')}.log")

  File.open(filename, 'w+') do |f|
    f.write("Exception caught: #{e.class}: #{e.message}")
    f.write(e.backtrace.join("\n  "))
    f.write("\n\n")
  end
end

