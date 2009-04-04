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


#
# Hosts whose IP address is trusted get automatically through.
#
class RuoteRest::RackWhiteListing

  def initialize (rack_app)
    @rack_app = rack_app
  end

  # authenticate the request against all our enable authentication options
  #
  def call (env)

    env['RUOTE_AUTHENTICATED'] =
      RuoteRest::Host.authenticate(env['REMOTE_ADDR'])

    @rack_app.call(env)
  end
end

#
# HTTP basic authentication
#
class RuoteRest::RackBasicAuth < Rack::Auth::Basic

  def initialize (parent_app, realm)
    super(parent_app)
    self.realm = realm
  end

  def call (env)

    unless env['RUOTE_AUTHENTICATED']

      auth = Rack::Auth::Basic::Request.new(env)

      return unauthorized unless auth.provided?
      return bad_request unless auth.basic?
      return unauthorized unless RuoteRest::User.authenticate(*auth.credentials)

      env['REMOTE_USER'] = auth.username
      env['RUOTE_AUTHENTICATED'] = true
    end

    @app.call(env)
  end
end

