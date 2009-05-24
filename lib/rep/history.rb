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
# Made in Japan as opposed to Swiss Made.
#++


require 'atom/collection' # gem 'atom-tools'


module RuoteRest

  helpers do

    def render_history_html (history)

      _erb(
        :history,
        :layout => :html,
        :locals => history)
    end

    def render_history_xml (history, options={ :indent => 2 })

      OpenWFE::Xml::builder(options) do |xml|

        xml.history(
          :count => history[:entries].size,
          :total => history[:total],
          :offset => history[:offset],
          :limit => history[:limit]) do

          history[:entries].each do |entry|
            xml.entry do
              xml.created_at entry.created_at
              xml.source entry.source
              xml.event entry.event
              xml.wfid entry.wfid
              xml.fei entry.fei
              xml.participant entry.participant
              xml.message entry.message
            end
          end
        end
      end
    end

    def render_history_json (history)

      h = history[:entries].collect { |e|
        {
          'created_at' => e.created_at,
          'source' => e.source,
          'event' => e.event,
          'wfid' => e.wfid,
          'fei' => e.fei,
          'participant' => e.participant,
          'message' => e.message
        }
      }

      OpenWFE::Json.encode( h )
    end

    def render_history_atom (history)

      feed = Atom::Feed.new(
        "http://#{request.host}:#{request.port}#{request.fullpath}")

      feed.title = "history feed for http://#{request.host}:#{request.port}"

      feed.authors.new(
        :name => 'ruote-rest', :uri => 'http://openwferu.rubyforge.org')

      feed.links << Atom::Link.new(
        :rel => 'self',
        :href => "http://#{request.host}:#{request.port}#{request.fullpath}")

      history[:entries].each do |e|

        entry = Atom::Entry.new
        entry.id = md5(
          "#{e.created_at}--#{e.source}--#{e.event}--#{e.wfid}--#{e.fei}")

        fei = e.fei ? OpenWFE::FlowExpressionId.from_s(e.fei) : nil
        fei = fei ? "#{fei.expname} #{fei.expid}" : ""

        entry.title = "#{e.event} #{e.wfid} #{fei} #{e.participant}"

        entry.links << Atom::Link.new(
          :rel => 'related',
          :href => request.href('processes', e.wfid)) if e.wfid and e.wfid != '0'

        entry.published = e.created_at

        entry.content = <<-EOS
          <div class="history_entry">
            <div class="created_at">#{e.created_at}</div>
            <div class="source">#{e.source}</div>
            <div class="wfid">#{e.wfid}</div>
            <div class="fei">#{e.fei}</div>
            <div class="event">#{e.event}</div>
            <div class="participant">#{e.participant}</div>
            <div class="message">#{e.message}</div>
          </div>
        EOS
        entry.content['type'] = 'xhtml'

        feed << entry
      end

      feed.to_s
    end
  end

end

