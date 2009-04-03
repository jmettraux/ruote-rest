require 'rack/auth/basic'
require 'conf/auth_models.rb'
require 'password.rb'


#
# TODO : maybe move the two auth classes to lib/
#        (and leave the real config stuff here)
#

#
# a wrapper for handling our authentication options
#


class OpenWFE::RackWhiteListing

  def initialize (rack_app)
    @rack_app = rack_app
  end

  #
  # authenticate the request against all our enable authentication options
  #
  def call (env)

    #env['RUOTE_AUTHENTICATED'] = AUTH_CONF['allowed_hosts'].include?(env['REMOTE_ADDR'])

    env['RUOTE_AUTHENTICATED'] = OpenWFE::Extras::Host.exists?(:ip => env['REMOTE_ADDR'], :trusted => true)
    @rack_app.call(env)
  end
end

class OpenWFE::RackBasicAuth < Rack::Auth::Basic
  include Password

  def call (env)

    unless env['RUOTE_AUTHENTICATED']

      auth = Rack::Auth::Basic::Request.new(env)

      return unauthorized unless auth.provided?
      return bad_request unless auth.basic?
      return unauthorized unless valid?(auth)
      return unauthorized unless valid_host?(env['REMOTE_ADDR'])


      env['REMOTE_USER'] = auth.username
      env['RUOTE_AUTHENTICATED'] = true
    end

    @app.call(env)
  end

  private

=begin
  def valid? (auth)

    user, pass = auth.credentials

    (AUTH_CONF['users'][user] == pass)
  end
=end

  def valid? (auth)

    user_login, user_pass = auth.credentials

    user = OpenWFE::Extras::User.find_by_login(user_login)

    user ? check_password(user.password, user_pass) : false
  end

  def valid_host? (host_ip)

    info = OpenWFE::Extras::Host.find :first, :conditions => ["ip = ?", host_ip]
    hour = Time.now.hour

    if info
      if ((info.from == nil) && (info.to == nil))
	true
      else
	((info.from.to_i < hour) && (info.to.to_i > hour))   #simple check for time availability. this may be improved as needed...
      end
    end

  end
end

#
# the actual configuration job

# now we don't load a configuration file with users and passwords in plain text

=begin
if File.exists?( auth_config_file = File.join( File.dirname(__FILE__), 'authentication.yaml' ) )
  AUTH_CONF = YAML::load_file( auth_config_file )[$env]
  raise(
    ArgumentError,
    "No authentication configuration specified for #{$env} environment!"
  ) if AUTH_CONF.nil?
else
  AUTH_CONFIG = { 'enabled' => false }
end
=end

#if AUTH_CONF['enabled']

#  if AUTH_CONF['basic_auth']

    $app = OpenWFE::RackBasicAuth.new($app)
    #$app.realm = AUTH_CONF['basic_auth_realm']
    $app.realm = 'ruote-rest'
#  end


#  $app = OpenWFE::RackWhiteListing.new($app) if AUTH_CONF['whitelisting']

   $app = OpenWFE::RackWhiteListing.new($app)
#end

# ($app always pointing to 'top' app, while $rr points to ruote-rest itself)
# (will certainly change)
