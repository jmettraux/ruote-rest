#--
# Copyright (c) 2008-2009, Kenneth Kalmer, Gonzalo Suarez, Nando Sola,
# John Mettraux. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# . Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
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

      return @app.call(env) \
        if env[:ruote_authenticated] and @opts[:trusting]

      blocking = @opts[:blocking]

      env[:ruote_authenticated] = nil if blocking

      clear(env)

      return @app.call(env) if env[:ruote_authenticated] or (not blocking)

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

