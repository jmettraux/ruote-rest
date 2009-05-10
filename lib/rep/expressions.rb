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

    # The YAML is the body of the request
    #
    def parse_expression_yaml (yaml)

      YAML.load(yaml)
    end

    # Fetches the YAML out of the 'yaml' request param
    #
    def parse_expression_form (_)

      yaml = request.params['yaml']
      YAML.load(yaml)
    end

    def parse_expression_tree_json (json)

      json_parse(json)
    end

    def parse_expression_tree_form (_)

      json_parse(request.params['tree'])
    end

    #
    # OUT

    #
    # expressions

    def render_expression_yaml (e)

      e.to_yaml
    end

    def render_expressions_xml (es, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)
      options[:short] = true

      OpenWFE::Xml.expressions_to_xml(es, options)
    end

    def render_expressions_json (es, options={})

      options[:linkgen] = RackLinkGenerator.new(request)
      options[:short] = true

      OpenWFE::Json.expressions_to_h(es, options).to_json
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
      expid += 'e' if fei.expname == 'environment'

      options[:builder].tag!(
        tagname,
        fei.to_s,
        :href => request.href(
          :expressions,
          fei.wfid,
          OpenWFE.to_uscores(expid)))
    end

    def render_expression_xml (e, options={ :indent => 2})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.expression_to_xml(e, options)
    end

    def render_expression_json (e, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.expression_to_h(e, options).to_json
    end

    def render_expression_tree_html (fexp)

      _erb(:expression_tree, :layout => :html, :locals => { :expression => fexp })
    end

    def render_expression_tree_json (fexp)

      fexp.raw_representation.to_json
    end

    #
    # stuff used in the expression.erb and expressions.erb

    # raw/env/exp icon for /expressions
    #
    def expression_symbol_src (fexp)

      src = case fexp
        when OpenWFE::RawExpression then 'raw.png' # should not happen
        when OpenWFE::Environment then 'env.png'
        else 'exp.png'
      end

      "/images/#{src}"
    end
  end
end

