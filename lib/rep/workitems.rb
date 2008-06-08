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

  #
  # IN

  def parse_workitem_xml (xml)

    OpenWFE::Xml.workitem_from_xml xml
  end

  def parse_workitem_form (x)

    wi = OpenWFE::InFlowWorkItem.new

    wi.attributes = JSON.parse(params[:attributes])

    wi._state = 'proceeded' if params[:proceed] == 'proceed'

    wi
  end


  #
  # OUT

  def render_workitems_xml (wis)

    builder do |xml|
      xml.instruct!
      xml.workitems :count => wis.size do
        wis.each do |wi|
          owi = wi.as_owfe_workitem
          owi._uri = request.href(:workitems, wi.id)
          OpenWFE::Xml._workitem_to_xml xml, owi
        end
      end
    end
  end

  def render_workitem_xml (wi)

    builder do |xml|
      xml.instruct!
      owi = wi.as_owfe_workitem
      owi._uri = request.href(:workitems, wi.id)
      OpenWFE::Xml._workitem_to_xml xml, owi
    end
  end

  def render_workitems_html (wis)

    @workitems = wis.sort_by { |wi| wi.participant_name }
    @workitems = @workitems.collect { |wi| wi.as_owfe_workitem }

    _erb :workitems, :layout => :html
  end

  def render_workitem_html (wi, detailed=true)

    @workitem = wi
    @workitem = wi.as_owfe_workitem if wi.is_a?(OpenWFE::Extras::Workitem)

    @detailed = detailed

    layout = @detailed ? :html : nil

    _erb :workitem, :layout => layout
  end

end

