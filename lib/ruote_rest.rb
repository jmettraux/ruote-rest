#--
# Copyright (c) 2008-2009, John Mettraux, OpenWFE.org
# All rights reserved.
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
# Made in Japan.
#++


require 'rexml/document'

require 'rufus/sixjo'

module RuoteRest
  extend Rufus::Sixjo

  VERSION = '0.9.21'
end


#
# conf

$env = ENV['ruote.environment'] || 'development'

require 'part.rb'

require 'db'
require 'engine'
require 'participants'

#
# misc

require 'patching'
require 'misc'

#
# representations (I'd prefer another name...)

load 'inout.rb'

load 'rep/links.rb'

load 'rep/service.rb'
load 'rep/fei.rb'
load 'rep/launchitems.rb'
load 'rep/processes.rb'
load 'rep/errors.rb'
load 'rep/expressions.rb'
load 'rep/participants.rb'
load 'rep/workitems.rb'
load 'rep/history.rb'

#
# resources

load 'res/service.rb'
load 'res/processes.rb'
load 'res/errors.rb'
load 'res/expressions.rb'
load 'res/participants.rb'
load 'res/workitems.rb'
load 'res/history.rb'

#
# helpers

load 'helpers/application.rb'
load 'helpers/links.rb'
load 'helpers/fluo.rb'

#
# '/' redirection

module RuoteRest

  get '/' do
    redirect request.href(:service)
  end
end

#
# Racking

Rufus::Sixjo.view_path = RUOTE_BASE_DIR + '/views'

$rr = RuoteRest.new_sixjo_rack_app(
  Rack::File.new(File.join(RUOTE_BASE_DIR, 'public')), :environment => $env)
$app = $rr

load 'auth.rb'

