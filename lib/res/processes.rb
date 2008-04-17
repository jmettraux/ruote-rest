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
# Returns the statuses of all the process currently running in this ruote_rest
#
get "/processes" do

    header 'Content-Type' => 'application/xml'

    render_processes_xml $engine.list_process_status
end

#
# Launches a business process
#
post "/processes" do

    xml = request.env["rack.input"].read

    li = OpenWFE::Xml.launchitem_from_xml xml

    fei = $engine.launch li

    response.status = 201
    header 'Content-Type' => 'application/xml'
    header 'Location' => request.link(:processes, fei.wfid)
    OpenWFE::Xml.fei_to_xml fei
end

#
# Returns the detailed status of a process instance
#
get "/processes/:wfid" do

    wfid = params[:wfid]
    ps = $engine.process_status wfid

    throw :halt, [ 404, "no such process" ] unless ps

    header 'Content-Type' => 'application/xml'
    render_process_xml ps
end

#
# Cancels a process instance
#
delete "/processes/:wfid" do

    wfid = params[:wfid]

    $engine.cancel_process wfid

    response.status = 204
    nil
end

