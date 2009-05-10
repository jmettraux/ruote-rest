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

SERVICES = [ :processes, :workitems, :errors, :participants, :history ]


  helpers do

    def render_service_html (_)

      _erb(:service, :layout => :html)
    end

    def render_service_xml (_)

      OpenWFE::Xml::builder(:indent => 2) do |xml|
        xml.service do
          xml.workspace do
            SERVICES.each { |s| xml.collection :href => request.href(s) }
            xml.collection :href => request.href('processes', 0, 'variables')
          end
        end
      end
    end

    def render_service_atom (_)

      # TODO

      OpenWFE::Xml::builder(:indent => 2) do |xml|
        xml.service do
        end
      end
    end

    def render_service_json (_)

      h = SERVICES.collect { |s|
        { 'name' => s.to_s, 'href' => request.href(s) }
      }
      h << {
        'name' => 'engine_variables',
        'href' => request.href('processes', 0, 'variables')
      }
      h.to_json
    end

  end

end

