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
    # PROCESSES

    def render_processes_xml (ps, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.processes_to_xml(ps, options)
    end

    def render_processes_json (ps, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.processes_to_h(ps, options).to_json
    end

    def render_processes_html (ps)

      _erb(
        :processes,
        :layout => :html,
        :locals => { :processes => ps })
    end

    #
    # PROCESS

    def render_process_html (p, detailed=true)

      _erb(
        :process,
        :layout => detailed ? :html : false,
        :locals => { :process => p, :detailed => detailed })
    end

    def render_process_json (p, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.process_to_h(p, options).to_json
    end

    def render_process_xml (p, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.process_to_xml(p, options)
    end

    # some parsing...

    # Receiving a process representation in XML
    #
    def parse_process_xml (xml)

      elt = REXML::Document.new(xml).root
      elt = elt.owfe_first_elt_child 'paused'

      {
        :paused => (elt.text.downcase == 'true')
      }
    end

    def parse_process_form (x)

      {
        :paused => (request.params['paused'] == 'true')
      }
    end

    # misc...

    # Renders the process definition tree (potientally updated) as some JSON
    #
    def render_process_tree_json (expressions)

      expressions.tree.to_json
    end

    # Renders the variables as JSON.
    #
    def render_process_variables_json (variables)

      variables.to_json
    end

    # Renders the variables as XML.
    #
    def render_process_variables_xml (variables)

      OpenWFE::Xml.to_xml(variables, :indent => 2)
    end
  end
end

