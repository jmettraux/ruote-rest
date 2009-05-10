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


class Rufus::Sixjo::Context

  # Parses the representation sent in the request body
  #
  # If tolerant is set to true, will simply return nil when it fails to parse
  # the incoming representation.
  #
  def rparse (type, tolerant=false)

    request.body.rewind
    representation = request.body.read

    format = determine_in_format

    begin
      #p [ "parse_#{type}_#{format}", representation ]
      send("parse_#{type}_#{format}", representation)
    rescue Exception => e
      return nil if tolerant
      throw :done, [ 400, "failed to parse incoming representation" ]
    end
  end

  # The entry point for rendering any ruote-rest object
  #
  # (pronounce with a "rolling r")
  #
  def rrender (type, object, options={})

    format, ctype = determine_out_format(options)

    ctype = 'text/plain' if params[:plain]
      # useful for debugging

    response.status = options.delete(:status) || 200
    response.content_type = ctype

    options.each { |k, v| response.header[k] = v }

    set_etag(object.etag) \
      if object.respond_to?(:etag) and object.etag
    set_last_modified(object.timestamp) \
      if object.respond_to?(:timestamp) and object.timestamp
        #
        # where the conditional GET happens...


    unless format == 'js'

      body = send("render_#{type}_#{format}", object)

      body = body.gsub(', ', ",\n ") \
        if format == 'json' and ctype == 'text/plain'
          # a bit more readable for 'text/plain' output

      return body
    end

    varname = params[:var] || 'ruote_js'
    method = "render_#{type}_json"

    "var #{varname} = #{send(method, object)}"
  end

  # Simply reads the "Content-Type" header
  #
  def determine_in_format

    ct = request.env['CONTENT_TYPE'] || ''

    return 'form' if ct.index('form-')
    return 'json' if ct.index('application/json')
    return 'yaml' if ct.index('application/yaml')

    'xml'
  end

  # some common formats
  #
  FORMATS = {

    :xml => [ 'xml', 'application/xml' ],
    :html => [ 'html', 'text/html' ],
    :json => [ 'json', 'application/json' ],
    :js => [ 'js', 'text/javascript' ],
    :yaml => [ 'yaml', 'application/yaml' ],
    :atom => [ 'atom', 'application/atom+xml' ]

  } unless defined?(FORMATS)

  FTYPES = FORMATS.keys.collect { |k| k.to_s } \
    unless defined?(FTYPES)

  # Determines the format the client is expecting
  #
  def determine_out_format (options={})

    f = options[:format] || params[:format] || request.env['_FORMAT']

    return FORMATS[:xml] if f == 'xml'
    return FORMATS[:json] if f == 'json'
    return FORMATS[:js] if f == 'js'
    return FORMATS[:yaml] if f == 'yaml'
    return FORMATS[:atom] if f == 'atom'

    accept = request.env['HTTP_ACCEPT'] || ''

    return FORMATS[:html] if accept.index('text/html')
    return FORMATS[:yaml] if accept.index('yaml')
    return FORMATS[:json] if accept.index('json')
    return FORMATS[:js] if accept.index('js')
    return FORMATS[:atom] if accept.index('atom')

    FORMATS[:xml]
  end

  # Returns true if the string is something like "xxx.json" or "yyy.xml"
  #
  def has_filetype? (s)

    ss = s.split('.')
    return false if ss.length != 2

    FTYPES.include?(ss.last)
  end

end

