
TRUSTED_HOSTS = [

    nil,
    '127.0.0.1'

] unless defined?(TRUSTED_HOSTS)

#
# called before each request
#
before do

    throw :halt, [ 401, "get off !" ] \
        unless TRUSTED_HOSTS.include?(request.env['REMOTE_ADDR'])
end

