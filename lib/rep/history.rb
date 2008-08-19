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


helpers do

  def render_history_html (history)

    _erb(
      :history,
      :layout => :html,
      :locals => history)
  end

  def render_history_xml (history)

    builder(2) do |xml|

      xml.instruct!

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
end

