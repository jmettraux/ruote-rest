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


module Rufus::Sixjo::Erb

  def _erb (template, opts={})

    (opts[:locals] ||= {})[:template] = template

    if opts[:layout]
      "#{erb(:header, opts)}#{erb(template, opts)}#{erb(:footer, opts)}"
    else
      erb(template, opts)
    end
  end
end


module RuoteRest

  helpers do

    def some_javascript
      <<-EOS
<script>
  function show (eltid) {
    elt = document.getElementById(eltid);
    elt.style.display = "block";
  }
  function hide (eltid) {
    elt = document.getElementById(eltid);
    elt.style.display = "none";
  }
</script>
      EOS
    end

    #
    #     display_time(workitem, :dispatch_time)
    #         # => Sat Mar 1 20:29:44 2008 (1d16h18m)
    #
    def display_time (object, accessor)

      t = object.send(accessor)

      t ? "#{t.ctime} (#{display_since(t)})" : ''
    end

    #
    #     display_since(workitem, :dispatch_time)
    #         # => 1d16h18m
    #
    def display_since (object, accessor=nil)

      t = accessor ? object.send(accessor) : object

      return '' unless t

      d = Time.now - t

      Rufus::to_duration_string(d, :drop_seconds => true)
    end

    def page_link (respath, offset, limit, text)
      "<a href=\"#{respath}?offset=#{offset}&limit=#{limit}\">#{text}</a> "
    end

    def paging (respath, offset, limit, total)

      s = ''

      s << page_link(respath, 0, limit, '|&lt;') \
        if offset != 0

      s << page_link(respath, offset - limit, limit, '&lt;') \
        if offset - limit > 0

      s << " #{offset} to #{offset + limit} / #{total} "

      s << page_link(respath, offset + limit, limit, '&gt;') \
        if offset + 2 * limit < total

      s << page_link(respath, total - limit, limit, '&gt;|') \
        if offset + limit < total

      "<div class=\"pager\">#{s}</div>"
    end

    # renders an information/message page
    #
    def render_reply (status, message)

      format, type = determine_out_format

      response.status = status

      if format == 'xml'

        "<message>#{message}</message>"

      elsif format == 'json'

        message.to_json

      else

        _erb(:reply, :layout => :html, :locals => { :message => message })
      end
    end

  end

end

