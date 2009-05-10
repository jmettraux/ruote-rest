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

    def render_errors_xml (errors, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.errors_to_xml(errors, options)
    end

    def render_error_xml (error, options={ :indent => 2 })

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Xml.error_to_xml(error, options)
    end

    def render_errors_json (errors, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.errors_to_h(errors, options).to_json
    end

    def render_error_json (error, options={})

      options[:linkgen] = RackLinkGenerator.new(request)

      OpenWFE::Json.error_to_h(error, options).to_json
    end

    def render_errors_html (errors)

      _erb(
        :errors,
        :layout => :html,
        :locals => { :errors => errors })
    end

    def render_error_html (error, alone=true)

      _erb(
        :error,
        :layout => alone ? :html : false,
        :locals => { :error => error, :alone => alone })
    end

  end

end

