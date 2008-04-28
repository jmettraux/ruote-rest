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
# IN

def parse_participant_json (json)

    JSON.parse json
end

def parse_participant_form (x)

    [ params[:regex], params[:class] ]
end

#
# OUT

def render_participants_xml (ps)

    builder do |xml|
        xml.instruct!
        xml.participants :count => ps.size do
            ps.each_with_index do |part, i|
                _render_participant_xml xml, part, i
            end
        end
    end
end

def render_participants_html (ps)

    @participants = ps

    _erb :participants, :layout => :html
end

def render_participant_xml (part)

    builder do |xml|
        xml.instruct!
        _render_participant_xml xml, part
    end
end

def render_participant_html (part, alone=true)

    @participant = part

    layout = alone ? :html : nil

    _erb :participant, :layout => layout
end

def _render_participant_xml (xml, part, index=nil)

    regex, participant = part

    opts = {}
    opts[:link] = request.link(:participants, index) if index

    xml.participant opts do
        xml.index(index.to_s) if index
        xml.regex regex.original_string
        xml.tag! :class, participant.class.name
    end
end

