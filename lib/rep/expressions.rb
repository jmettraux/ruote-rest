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

  #
  # The YAML is the body of the request
  #
  def parse_expression_yaml (yaml)

    YAML.load yaml
  end

  #
  # fetches the YAML out of the 'yaml' request param
  #
  def parse_expression_form (_)

    yaml = request.params['yaml']
    YAML.load yaml
  end

  def parse_expression_raw_json (json)

    json_parse(json)
  end

  def parse_expression_raw_form (_)

    json_parse(request.params['tree'])
  end

  #
  # OUT

  #
  # expressions

  def render_expression_yaml (e)

    e.to_yaml
  end

  def render_expressions_xml (es)

    options = { :indent => 2 }

    OpenWFE::Xml::builder(options) do |xml|

      xml.expressions :count => es.size do

        es.sort_by { |e| e.fei.expid }.each do |fexp|
          render_expression_xml(fexp, options)
        end

        xml.process_representation es.representation.to_json
      end
    end
  end

  def render_expressions_html (es)

    _erb(
      :expressions,
      :layout => :html,
      :locals => { :expressions => es })
  end

#
# expression

  def render_expression_html (e, detailed=true)

    _erb(
      :expression,
      :layout => detailed ? :html : nil,
      :locals => { :expression => e, :detailed => detailed })
  end

  def expression_link (tagname, fei, options={})

    return unless fei

    expid = fei.expid
    expid += "e" if fei.expname == 'environment'

    options[:builder].tag!(
      tagname,
      fei.to_s,
      :href => request.href(
        :expressions,
        fei.wfid,
        swapdots(expid)))
  end

  def render_expression_xml (e, options={ :indent => 2})

    OpenWFE::Xml::builder(options) do |xml|

      params = {
        :href => request.href(:expressions, e.fei.wfid, swapdots(e.fei.expid)) }

      xml.expression(params) do

        xml.tag! "class", e.class.name
        xml.name e.fei.expression_name
        xml.apply_time OpenWFE::Xml.to_httpdate(e.apply_time)

        OpenWFE::Xml.fei_to_xml(e.fei, options)

        #
        # parent id

        expression_link('parent', e.parent_id, options)

        #
        # environment id

        expression_link('environment', e.environment_id, options)

        #
        # children

        xml.children do
          e.children.each do |c|
            expression_link('child', c, options)
          end
        end if e.children

        #
        # process/expression representations

        xml.raw_representation(e.raw_representation.to_json) \
          if e.raw_representation
        xml.raw_rep_updated(e.raw_rep_updated.to_json) \
          if e.raw_rep_updated

        #
        # variables

        hash_to_xml(xml, :variables, e, :variables) \
          if e.is_a?(OpenWFE::Environment)
      end
    end
  end

  def render_expression_raw_html (fexp)

    _erb :expression_raw, :layout => :html, :locals => { :expression => fexp }
  end

  def render_expression_raw_json (fexp)

    fexp.raw_representation.to_json
  end

  #
  # stuff used in the expression.erb and expressions.erb

  #
  # raw/env/exp icon for /expressions
  #
  def expression_symbol_src (fexp)

    src = case fexp
      when OpenWFE::RawExpression then 'raw.png'
      when OpenWFE::Environment then 'env.png'
      else 'exp.png'
    end

    "/images/#{src}"
  end

end

