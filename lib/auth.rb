#--
# Copyright (c) 2008-2009, Kenneth Kalmer, Gonzalo Suarez, Nando Sola,
# John Mettraux.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Africa and Spain.
#++


require 'rack/auth/basic'
require 'models/auth'


module RuoteRest

  #
  # The call() impl common to the auth middlewares here.
  #
  # Calls a hypothetical clear(env) method if auth is required.
  #
  module AuthBehaviourMixin

    def call (env)

      return @app.call(env) if env[:ruote_authenticated]

      env.delete(:ruote_authenticated)

      clear(env)

      return @app.call(env) if env[:ruote_authenticated] != false

      env[:auth_response] || [ 401, {}, 'get off !' ]
    end
  end

  #
  # Hosts whose IP address is trusted get automatically through.
  #
  class RackWhiteListing
    include AuthBehaviourMixin

    def initialize (app, opts={})
      @app = app
      @opts = opts
    end

    protected

    def clear (env)

      env[:ruote_authenticated] =
        RuoteRest::Host.authenticate(env['REMOTE_ADDR'])
          #
          # sets
          #
          # * true   : known and trusted
          # * nil    : known but has to go through further check
          # * false  : not known, block
    end
  end

  #
  # HTTP basic authentication
  #
  class RackBasicAuth < Rack::Auth::Basic
    include AuthBehaviourMixin

    def initialize (app, opts={})
      super(app)
      self.realm = opts[:realm] || 'ruote-rest'
      @opts = opts
    end

    protected

    def clear (env)

      auth = Rack::Auth::Basic::Request.new(env)

      env[:ruote_authenticated] = false

      if not auth.provided?
        env[:auth_response] = unauthorized
      elsif not auth.basic?
        env[:auth_response] = bad_request
      elsif not User.authenticate(*auth.credentials)
        env[:auth_response] = unauthorized
      else
        env['REMOTE_USER'] = auth.username
        env[:ruote_authenticated] = true
      end
    end
  end

end

