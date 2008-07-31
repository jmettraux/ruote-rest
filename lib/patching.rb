#
#--
# Copyright (c) 2008, John Mettraux, OpenWFE.org
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
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#


#
# Reopening Rack::Request to add some convenience methods
#
class Rack::Request

  #
  #   request.href(:expressions, "abc", "0_0_1")
  #   #=> "http://example.org:4567/expressions/abc/0_0_1"
  #
  def href (*args)

    base = "#{scheme}://#{host}"

    if (scheme == 'https' && port != 443) ||
       (scheme == 'http' && port != 80)

      base << ":#{port}"
    end

    base + "/" + args.collect {|a| a.to_s }.join("/")
  end
end


#
# assumes the including class has a href() method, provides a link(req)
# method.
#
module RuoteLinkable

  def link (request)
    "<a href=\"#{href(request)}\">GET #{href}</a>"
  end
end


#
# reopening some OpenWFE classes to add some link magic
#

class OpenWFE::FlowExpressionId
  include RuoteLinkable

  #
  # Returns the relative link to the expression pointed at by this
  # FlowExpressionId.
  #
  #   fei.href
  #     # => "/expressions/{wfid}/{expid}"
  #
  #   fei.href(request)
  #     # => "http://host:port/expressions/{wfid}/{expid}"
  #
  #   fei.href(request, 'smurfs')
  #     # => "http://host:port/smurfs/{wfid}/{expid}"
  #
  #   fei.href(nil, 'smurfs')
  #     # => "smurfs/{wfid}/{expid}"
  #
  def href (req=nil, resource_name='expressions')

    ei = swapdots self.expid

    return req.href(resource_name, wfid, ei) if req

    env = self.expname == "environment" ? "e" : ""

    "/#{resource_name}/#{wfid}/#{ei}#{env}"
  end
end

class OpenWFE::ProcessStatus
  include RuoteLinkable

  #
  # Returns the 'ruote-rest' href for this ProcessError instance
  #
  def href (request=nil)

    return request.href(:processes, wfid) if request

    "/processes/#{wfid}"
  end
end

class OpenWFE::FlowExpression
  include RuoteLinkable

  #
  # a shortcut for
  #
  #   self.fei.href(req)
  #
  def href (request=nil)

    fei.href(request)
  end
end

class OpenWFE::InFlowWorkItem
  include RuoteLinkable

  #
  # Returns the 'ruote-rest' href for this workitem
  #
  def href (request=nil)

    return request.href(:workitems, db_id) if request

    "/workitems/#{db_id}"
  end
end

class OpenWFE::ProcessError
  include RuoteLinkable

  def error_id

    swapdots(fei.expid) +
    "_" +
    Rufus::Mnemo.from_integer(date.to_i.abs)
      # 2008 AD, but what about 2008 BC ?
  end

  #
  # Returns the 'ruote-rest' href for this ProcessError instance
  #
  def href (request=nil)

    return request.href(:errors, wfid, expid) if request

    "/errors/#{wfid}/#{error_id}"
  end
end

