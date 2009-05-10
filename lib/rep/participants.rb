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


module RuoteRest

  helpers do

    #
    # IN

    def parse_participant_json (json)

      json_parse(json)
    end

    def parse_participant_form (x)

      store_name = params[:store_name]
      store_name = nil if store_name.strip == ''

      [ params[:regex], params[:class], store_name ]
    end

    #
    # OUT

    def render_participants_xml (ps, options={ :indent => 2 })

      OpenWFE::Xml::builder(options) do |xml|
        xml.participants :count => ps.size do
          ps.each do |participant|
            render_participant_xml participant, options
          end
        end
      end
    end

    def render_participants_html (ps)

      _erb(
        :participants,
        :layout => :html,
        :locals => { :participants => ps })
    end

    def render_participant_html (part, detailed=true)

      _erb(
        :participant,
        :layout => detailed ? :html : nil,
        :locals => { :participant => part, :detailed => detailed })
    end

    def render_participant_xml (part, options={ :indent => 2})

      OpenWFE::Xml::builder(options) do |xml|

        regex, participant = part

        params = {
          :href =>
          request.href(:participants, uri_escape(regex.original_string)) }

        xml.participant(params) do
          xml.regex regex.original_string
          xml.tag! :class, participant.class.name
        end
      end
    end

  end

end

