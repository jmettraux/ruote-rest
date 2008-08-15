
#
# called before each request
#
#before do
#
#  throw :halt, [ 401, "get off !" ] \
#    unless [
#      nil, '127.0.0.1'
#    ].include?(request.env['REMOTE_ADDR'])
#
#  # TODO : add support for some authentication
#end

