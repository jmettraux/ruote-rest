
require 'rack/auth/basic'

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

    env['RUOTE_AUTHENTICATED'] = AUTH_CONF['allowed_hosts'].include?(env['REMOTE_ADDR'])

    @rack_app.call(env)
  end

  #def authenticate_by_password
  #  @rack_app = Rack::Auth::Basic.new(@rack_app) do |username, password|
  #    @config['users'][username] && @config['users'][username] == password
  #  end
  #  @rack_app.realm = @config['basic_auth_realm']
  #end
end

class OpenWFE::RackBasicAuth < Rack::Auth::Basic

  def call (env)

    unless env['RUOTE_AUTHENTICATED']

      auth = Rack::Auth::Basic::Request.new(env)

      return unauthorized unless auth.provided?
      return bad_request unless auth.basic?
      return unauthorized unless valid?(auth)

      env['REMOTE_USER'] = auth.username
      env['RUOTE_AUTHENTICATED'] = true
    end

    @app.call(env)
  end

  private

  def valid? (auth)

    user, pass = auth.credentials

    (AUTH_CONF['users'][user] == pass)
  end
end


#
# the actual configuration job

AUTH_CONF = YAML::load_file(
  File.join( File.dirname(__FILE__), 'authentication.yaml' )
)[$env]

raise(
  ArgumentError, "No configuration specified for #{$env} environment!"
) if AUTH_CONF.nil?


if AUTH_CONF['enabled']
  
  if AUTH_CONF['basic_auth']

    $app = OpenWFE::RackBasicAuth.new($app)
    $app.realm = AUTH_CONF['basic_auth_realm']
  end
  
  $app = OpenWFE::RackWhiteListing.new($app) if AUTH_CONF['whitelisting']

end

# ($app always pointing to 'top' app, while $rr points to ruote-rest itself)
# (will certainly change)

