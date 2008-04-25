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

    representation = request.env["rack.input"].read

    format = determine_in_format

    send "parse_#{type}_#{format}", representation
end

#
# the entry point for rendering any ruote-rest object
#
# (pronounce with a "rolling r")
#
def rrender (type, object, options={})

    format, ctype = determine_out_format

    response.status = options.delete(:status) || 200

    header 'Content-Type' => ctype
    options.each { |k, v| header(k => v) }

    method_name = "render_#{type}_#{format}"

    begin

        send method_name, object

    rescue Exception => e

        puts e

        header 'Content-Type' => 'application/xml'
        send "render_#{type}_xml", object
    end
end

#
# simply reads the "Content-Type" header
#
def determine_in_format

    ct = request.env['CONTENT_TYPE']

    return "form" if ct.index("form-")

    "xml"
end

#
# determines the format the client is expecting by reading the "Accept"
# request header
#
def determine_out_format

    accept = request.env['HTTP_ACCEPT'] || ""

    return [ "html", "text/html" ] if accept.index("text/html")

    [ "xml", "application/xml" ]
end

