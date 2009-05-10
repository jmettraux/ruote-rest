#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
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
# Made in Japan.
#++


require 'rexml/document'

require 'rufus/sixjo'

module RuoteRest
  extend Rufus::Sixjo

  def self.build_rack_app (parent, options={})
    @app = new_sixjo_rack_app(parent, options)
    # returns @app
  end

  def self.app
    @app
  end

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
# representations

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
load 'rep/hashes.rb'
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
# '/' redirection and more

module RuoteRest

  get '/' do
    redirect request.href(:service)
  end
end

#
# Racking

Rufus::Sixjo.view_path = RUOTE_BASE_DIR + '/views'

load 'auth.rb'

