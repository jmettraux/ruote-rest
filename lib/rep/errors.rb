#--
# Copyright (c) 2008-2009, John Mettraux, OpenWFE.org
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
#
# Made in Japan.
#++


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

