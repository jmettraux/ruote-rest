
#
# tune authentication at will here
#

#
# a wrapper for handling our authentication options
# 
class OpenWFE::RackAuth
  
  def initialize( rack_app )
    @rack_app = rack_app
    
    @config = YAML::load_file( 
      File.join( File.dirname(__FILE__), 'authentication.yaml' ) 
    )[$env]
    
    raise ArgumentError, "No configuration specified for #{$env} environment!" if @config.nil?
  end
  
  #
  # authenticate the request against all our enable authentication options
  def call( env )
    if @config['enabled']
      authenticate_by_ip(env) || authenticate_by_password
    end
    
    @rack_app.call( env )
  end
  
  def authenticate_by_ip(env)
    if @config['whitelisting']
      auth_passed = @config['allowed_hosts'].include?(env['REMOTE_ADDR'])
    end
    
    if !auth_passed && !@config['basic_auth']
      throw :done, [ 401, "get off !" ]
    end
    auth_passed
  end
  
  def authenticate_by_password
    @rack_app = Rack::Auth::Basic.new(@rack_app) do |username, password|
      @config['users'][username] && @config['users'][username] == password
    end
    @rack_app.realm = @config['basic_auth_realm']
  end
  
  # Is this sane?!? It gets the tests to run and I'm not familiar with Rack...
  def method_missing( method_name, *args )
    @rack_app.send( method_name, *args )
  end
end

# Only continue if allowed
$app = OpenWFE::RackAuth.new( $app )

# ($app always pointing to 'top' app, while $rr points to ruote-rest itself)
# (will certainly change)

