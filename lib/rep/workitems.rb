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

    def parse_workitem_xml (xml)

      OpenWFE::Xml.workitem_from_xml(xml)
    end

    def parse_workitem_form (x)

      wi = OpenWFE::InFlowWorkItem.new

      wi.attributes = json_parse(params[:attributes])

      wi._state = 'proceeded' if params[:proceed] == 'proceed'
        # TODO : align with ruote-web2 params[:state]

      wi
    end

    def parse_workitem_json (json)

      OpenWFE.workitem_from_h(json_parse(json))
    end


    #
    # OUT

    def render_workitems_xml (wis, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.workitems_to_xml(
        wis.collect { |wi|
          wi.is_a?( OpenWFE::Extras::Workitem ) ?
            wi.to_owfe_workitem(options) : wi.to_owfe_workitem
        },
        options)
    end

    def render_workitem_xml (wi, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.workitem_to_xml(
        wi.is_a?( OpenWFE::Extras::Workitem ) ?
          wi.to_owfe_workitem(options) : wi.to_owfe_workitem,
        options)
    end

    def render_workitems_json (wis, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.encode(OpenWFE::Json.workitems_to_h(wis, options))
    end

    def render_workitem_json (wi, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.encode(OpenWFE::Json.workitem_to_h(wi, options))
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

      wi = wi.as_owfe_workitem if wi.is_a?(OpenWFE::Extras::ArWorkitem)

      _erb(
        :workitem,
        :layout => detailed ? :html : nil,
        :locals => { :workitem => wi, :detailed => detailed })
    end

  end

end

