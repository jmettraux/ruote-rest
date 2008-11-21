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


#
# parses the representation sent in the request body
#
def rparse (type)

  representation = request.body.read

  format = determine_in_format

  send("parse_#{type}_#{format}", representation) \
    rescue throw :done, [ 400, "failed to parse incoming representation" ]
end

#
# the entry point for rendering any ruote-rest object
#
# (pronounce with a "rolling r")
#
def rrender (type, object, options={})

  format, ctype = determine_out_format options

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

    body = body.gsub(", ", ",\n ") if format == 'json' and ctype == 'text/plain'
      # a bit more readable for 'text/plain' output

    return body
  end

  varname = params[:var] || 'ruote_js'
  method = "render_#{type}_json"

  "var #{varname} = #{send(method, object)}"
end

#
# simply reads the "Content-Type" header
#
def determine_in_format

  ct = request.env['CONTENT_TYPE']

  return 'form' if ct.index('form-')
  return 'json' if ct.index('application/json')
  return 'yaml' if ct.index('application/yaml')

  'xml'
end


#
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

#
# determines the format the client is expecting
#
def determine_out_format (options)

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

#
# Returns true if the string is something like "xxx.json" or "yyy.xml"
#
def has_filetype? (s)

  ss = s.split('.')
  return false if ss.length != 2

  FTYPES.include?(ss.last)
end

