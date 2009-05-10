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

    # Builds a launchitem from its XML representation
    #
    def parse_launchitem_xml (xml)

      OpenWFE::Xml.launchitem_from_xml xml
    end

    # TODO : parse_launchitem_json (json)

    # Builds a launchitem from the request parameters (html form)
    #
    def parse_launchitem_form (x)

      url = request.params['pdef_url']
      pdef = request.params['pdef']
      fields = json_parse(request.params['fields'])

      if pdef.strip != ''
        li = OpenWFE::LaunchItem.new pdef
      else
        li = OpenWFE::LaunchItem.new
        li.workflow_definition_url = url
      end

      li.attributes.merge! fields

      li
    end

    #
    # OUT

  end

end

