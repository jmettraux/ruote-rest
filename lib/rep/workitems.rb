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

    wi.attributes = json_parse(params[:attributes])

    wi._state = 'proceeded' if params[:proceed] == 'proceed'
      # TODO : align with ruote-web2 params[:state]

    wi
  end

  def parse_workitem_json (json)

    OpenWFE::workitem_from_h(json_parse(json))
  end


  #
  # OUT

  def render_workitems_xml (wis, options={ :indent => 2 })

    options[:linkgen] = RackLinkGenerator.new(request)

    OpenWFE::Xml.workitems_to_xml(
      wis.collect { |wi| wi.to_owfe_workitem(options) },
      options)
  end

  def render_workitem_xml (wi, options={ :indent => 2 })

    options[:linkgen] = RackLinkGenerator.new(request)

    OpenWFE::Xml.workitem_to_xml(wi.to_owfe_workitem(options), options)
  end

  def render_workitems_json (wis, options={})

    options[:linkgen] = RackLinkGenerator.new(request)

    OpenWFE::Json.workitems_to_h(wis, options).to_json
  end

  def render_workitem_json (wi, options={})

    options[:linkgen] = RackLinkGenerator.new(request)

    OpenWFE::Json.workitem_to_h(wi, options).to_json
  end

  def render_workitems_html (wis)

    wis = wis.sort_by { |wi| wi.participant_name.to_s }
    wis = wis.collect { |wi| wi.as_owfe_workitem }

    _erb(
      :workitems,
      :layout => :html,
      :locals => { :workitems => wis })
  end

  def render_workitem_html (wi, detailed=true)

    wi = wi.as_owfe_workitem if wi.is_a?(OpenWFE::Extras::Workitem)

    _erb(
      :workitem,
      :layout => detailed ? :html : nil,
      :locals => { :workitem => wi, :detailed => detailed })
  end

end

