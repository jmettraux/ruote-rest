#
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
#++
#

#
# "made in Japan" as opposed to "swiss made"
#
# John Mettraux at openwfe.org
#

require 'atom/collection' # gem 'atom-tools'


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

    history[:entries].collect { |e|
      {
        'created_at' => e.created_at,
        'source' => e.source,
        'event' => e.event,
        'wfid' => e.wfid,
        'fei' => e.fei,
        'participant' => e.participant,
        'message' => e.message
      }
    }.to_json
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

