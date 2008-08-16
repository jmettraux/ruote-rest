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

  def render_processes_xml (ps)

    builder(2) do |xml|
      xml.instruct!
      xml.processes :href => request.href(:processes), :count => ps.size do
        ps.each do |fei, process_status|
          _render_process_xml xml, process_status
        end
      end
    end
  end

  def render_processes_json (ps)

    ps.collect { |fei, s| s.to_h }.to_json
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

    p.to_h.to_json
  end

  def render_process_xml (p)

    builder do |xml|
      xml.instruct!
      _render_process_xml xml, p, true
    end
  end

  def _render_process_xml (xml, p, detailed=false)

    xml.process :href => request.href(:processes, p.wfid) do

      xml.wfid p.wfid
      xml.wfname p.wfname
      xml.wfrevision p.wfrevision

      xml.launch_time p.launch_time
      xml.paused p.paused

      xml.tags do
        p.tags.each { |t| xml.tag t }
      end

      xml.branches p.branches

      if detailed

        hash_to_xml xml, :variables, p, :variables

        xml.scheduled_jobs do
          p.scheduled_jobs.each do |j|
            xml.job do
              xml.type j.class.name
              xml.schedule_info j.schedule_info
              xml.next_time j.next_time.to_s
              xml.tags do
                j.tags.each { |t| xml.tag t }
              end
            end
          end
        end

        xml.active_expressions :href => request.href(:expressions, p.wfid) do

          p.expressions.each do |fexp|

            fei = fexp.fei

            xml.expression(
              "#{fei.to_s}",
              :short => fei.to_web_s,
              :href => fei.href(request))
          end
        end

        xml.errors :href => request.href(:errors, p.wfid), :count => p.errors.size do
          p.errors.each do |k, v|
            xml.error do
              #xml.stacktrace do
              #  xml.cdata! "\n#{v.stacktrace}\n"
              #end
              xml.fei v.fei.to_s
              xml.message v.stacktrace.split("\n")[0]
            end
          end
        end

        xml.representation(
          p.process_stack.representation.to_json,
          :href => request.href(:processes, p.wfid, :representation))

      else

        xml.errors :count => p.errors.size

      end
    end
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
  def render_process_representation_json (pstack)

    pstack.representation.to_json
  end

end

