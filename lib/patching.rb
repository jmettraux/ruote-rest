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


require 'digest/md5'


# A shortcut to ::Digest::MD5.hexdigest(s)
#
def md5 (s)
  ::Digest::MD5.hexdigest(s)
end


# Reopening Rack::Request to add some convenience methods
#
class Rack::Request

  #   request.href(:expressions, "abc", "0_0_1")
  #   #=> "http://example.org:4567/expressions/abc/0_0_1"
  #
  def href (*args)

    base = "#{scheme}://#{host}"

    if (scheme == 'https' && port != 443) ||
       (scheme == 'http' && port != 80)

      base << ":#{port}"
    end

    "#{base}/#{args.collect {|a| OpenWFE.to_uscores(a.to_s) }.join('/')}"
  end
end


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

    return req.href(resource_name, OpenWFE.to_uscores(wfid), ei) if req

    "/#{resource_name}/#{OpenWFE.to_uscores(wfid)}/#{ei}"
  end
end

class OpenWFE::ProcessStatus
  include RuoteLinkable

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

  # A shortcut for
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

  # Returns the 'ruote-rest' href for this ProcessError instance
  #
  def href (request=nil)

    #request ? request.href(:errors, wfid, fei.expid) : "/errors/#{wfid}/#{error_id}"
    request ?
      request.href(:errors, wfid, fei.expid) :
      "/errors/#{wfid}/#{OpenWFE.to_uscores(fei.expid)}"
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

