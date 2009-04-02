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


require 'digest/md5'


#
# a shortcut to ::Digest::MD5.hexdigest(s)
#
def md5 (s)
  ::Digest::MD5.hexdigest(s)
end


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

    "#{base}/#{args.collect {|a| a.to_s }.join('/')}"
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

    env = self.expname == 'environment' ? 'e' : ''
    ei = "#{OpenWFE.to_uscores(self.expid)}#{env}"

    return req.href(resource_name, wfid, ei) if req

    "/#{resource_name}/#{wfid}/#{ei}"
  end
end

class OpenWFE::ProcessStatus
  include RuoteLinkable

  #
  # Returns the 'ruote-rest' href for this ProcessError instance
  #
  def href (request=nil)

    request ? request.href(:processes, wfid) : "/processes/#{wfid}"
  end

  def etag

    @etag ||= md5("#{wfid}_#{timestamp.to_i}")
  end
end

#
# making sure that /expressions/:wfid has an etag and a last-modified
#
module OpenWFE::RepresentationMixin

  def etag
    return @etag if @etag
    root_exp = find_root_expression
    @etag ||= root_exp ? md5("#{root_exp.fei.wfid}__#{timestamp}") : nil
  end

  def timestamp
    @timestamp ||= self.max { |fexp0, fexp1|
      u0 = fexp0.updated_at || Time.at(0)
      u1 = fexp1.updated_at || Time.at(0)
      u0 <=> u1
    }.updated_at
  end
end

module OpenWFE::StatusesMixin

  def etag
    @etag ||= md5("#{object_id}_#{timestamp.to_i}")
      # object_id is reliable since the engine caches the statuses
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

  def etag
    md5("#{fei}__#{updated_at}")
  end

  def timestamp
    updated_at
  end
end

class OpenWFE::InFlowWorkItem
  include RuoteLinkable

  #
  # Returns the 'ruote-rest' href for this workitem
  #
  def href (request=nil)

    #i = "#{fei.wfid}/#{db_id}"
    #return request.href(:workitems, i) if request
    #"/workitems/#{i}"
    fei.href(request, 'workitems')
  end
end

#
# The deprecated activerecord based workitem, adding etag and timestamp...
#
class OpenWFE::Extras::Workitem

  def pretag
    "#{fei} #{store_name} #{last_modified} #{dispatch_time} " +
    "#{fields.collect { |f| f.fkey.to_s + ' ' + f.value.to_s }.join(', ')}"
  end

  def etag
    @etag ||= md5(pretag)
  end

  def timestamp
    last_modified
  end
end

#
# The new activerecord based workitem, adding etag and timestamp...
#
class OpenWFE::Extras::ArWorkitem
  
  def pretag
    "#{fei} #{store_name} #{last_modified} #{dispatch_time} " +
    "#{field_hash.collect { |key,value| key.to_s + ' ' + value.to_s }.join(', ')}"
  end

  def etag
    @etag ||= md5(pretag)
  end

  def timestamp
    last_modified
  end
end

class OpenWFE::ProcessError
  include RuoteLinkable

  def error_id

    OpenWFE.to_uscores(fei.expid) +
    '_' +
    Rufus::Mnemo.from_integer(date.to_i.abs)
      # 2008 AD, but what about 2008 BC ?
  end

  #
  # Returns the 'ruote-rest' href for this ProcessError instance
  #
  def href (request=nil)

    request ? request.href(:errors, wfid, expid) : "/errors/#{wfid}/#{error_id}"
  end

  def pretag
    "#{date}_#{fei}_#{message}"
  end

  def etag
    md5(pretag)
  end

  def timestamp
    date
  end
end

module ArrayEtagMixin
  def etag
    md5(collect { |e| e.pretag }.join('|'))
  end
  def timestamp
    m = max { |e0, e1|
      if e0.timestamp == nil
        -1
      elsif e1.timestamp == nil
        1
      else
        e0.timestamp <=> e1.timestamp
      end
    }
    m != nil ? m.timestamp : nil
  end
end

