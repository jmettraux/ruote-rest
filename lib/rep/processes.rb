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
  # PROCESSES

  def render_processes_xml (ps, options={ :indent => 2 })

    options[:request] = request
    OpenWFE::Xml.processes_to_xml(ps, options)
  end

  def render_processes_json (ps)

    ps.collect { |fei, s| s.to_h(request.method(:href)) }.to_json
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

  def render_process_json (p)

    p.to_h(request.method(:href)).to_json
  end

  def render_process_xml (p, options={ :indent => 2 })

    options[:request] = request
    OpenWFE::Xml.process_to_xml(p, options)
  end

  #
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

  # json

  #
  # Renders the process definition tree (potientally updated) as some JSON
  #
  def render_process_tree_json (expressions)

    expressions.tree.to_json
  end

  #
  # Renders the variables as JSON.
  #
  def render_process_variables_json (variables)

    variables.to_json
  end

  #
  # Renders the variables as XML.
  #
  def render_process_variables_xml (variables)

    OpenWFE::Xml.to_xml(variables, :indent => 2)
  end

end

