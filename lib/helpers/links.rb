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


module RuoteRest

  helpers do

    #
    # builds a GET link (<a ...>GET ...</a>)
    #
    def rlink (*args)

      # rel= ?
      # http://microformats.org/wiki/rel-design-pattern

      return args.first.link(request) \
        if args.size == 1 and args.first.respond_to?(:link)

      params = args.last.is_a?(Hash) ? args.pop : nil

      params = "?" + params.collect { |k, v|
        "#{k}=#{OpenWFE.to_uscores(v)}"
      }.join("&") if params

      params = '' unless params

      args = args.collect { |a| has_filetype?(a) ? a : OpenWFE.to_uscores(a) }

      "<a href=\"#{request.href(*args)}#{params}\">" +
      "GET /#{args.join('/')}#{params}" +
      "</a>"
    end

    #
    # returns the current URI
    #
    def here

      "#{request.scheme}://#{request.host}:#{request.port}" +
      "#{request.fullpath}"
    end

    #
    # returns the special href for debugging formats (plain=true)
    #
    def as_x_href (format)

      #href = here
      #href += href.index('?') ? '&' : '?'
      #href + "format=#{format}&plain=true"

      r = "#{request.scheme}://#{request.host}:#{request.port}"
      r << "#{request.script_name}#{request.path_info}.#{format}?plain=true"
      r << "&#{request.query_string}" if request.query_string.length > 0
      r
    end

  end

end

