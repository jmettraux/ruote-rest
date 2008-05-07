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

require 'cgi'


#
# swap from dots to underscores
#
#     swapdots "0_0_1" # => "0.0.1"
#
#     swapdots "0.0.1" # => "0_0_1"
#
def swapdots (s)

    return s.gsub(/\./, '_') if s.index(".")
    s.gsub(/\_/, '.')
end


#
#     render_time(workitem, :dispatch_time)
#         # => Sat Mar 1 20:29:44 2008 (1d16h18m)
#
def display_time (object, accessor)

    t = object.send accessor

    return "" unless t

    d = Time.now - t

    "#{t.ctime} (#{Rufus::to_duration_string(d, :drop_seconds => true)})"
end

#
# Basically, it's CGI escape(), but it makes sure that dots '.' are escaped
# as well.
#
def uri_escape (s)

    CGI.escape(s).gsub(/\./, '%2E')
end

#--
# Basically, it's CGI escape(), but it makes sure that dots '.' are escaped
# as well.
#
#def uri_unescape (s)
#    CGI.unescape s
#end
#++

