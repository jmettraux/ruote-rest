
#
# tune authentication at will here
#

#
# an ip address white list, might not be very useful in a wan scenario
#
class OpenWFE::RackWhiteList
  def initialize (next_app, &block)
    @next_app = next_app
    @block = block
  end
  def call (env)
    throw :done, [ 401, "get off !" ] unless @block.call(env['REMOTE_ADDR'])
    @next_app.call(env)
  end
end

$app = OpenWFE::RackWhiteList.new($app) do |ip_address|
  [ nil, '127.0.0.1' ].include?(ip_address)
end

#$app = Rack::Auth::Basic.new($app) do |username, password|
#  password == 'secret'
#end
#$app.realm = 'ruote-rest'

# ($app always pointing to 'top' app, while $rr points to ruote-rest itself)
# (will certainly change)

