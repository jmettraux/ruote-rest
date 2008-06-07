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

  rrender :processes, $engine.list_process_status
end

#
# Launches a business process
#
post "/processes" do

  launchitem = rparse :launchitem

  wait = (params[:wait] == 'true')

  fei = $engine.launch launchitem

  $engine.wait_for(fei) if wait

  rrender(
    :fei, fei,
    :status => 201, 'Location' => request.link(:processes, fei.wfid))
end

#
# just return the process instance tree as JSON
#
get "/processes/:wfid/representation" do

  pstack = $engine.process_stack params[:wfid], true

  throw :halt, [ 404, "no such process" ] unless pstack

  rrender :process_representation, pstack, :format => 'json'
end

#
# Returns the detailed status of a process instance
#
get "/processes/:wfid" do

  wfid = params[:wfid]

  pstatus = get_status_and_stack

  rrender :process, pstatus
end

#
# Updates a process instance (pauses or resumes it).
#
put "/processes/:wfid" do

  pstatus = get_process_status
  process = rparse :process

  if process[:paused]
    $engine.pause_process pstatus.wfid
  else
    $engine.resume_process pstatus.wfid
  end

  rrender :process, get_status_and_stack
end

#
# Cancels a process instance
#
delete "/processes/:wfid" do

  wfid = params[:wfid]

  $engine.cancel_process wfid

  sleep 0.350

  response.status = 303
  header "Location" => request.link(:processes)
  "process #{wfid} deleted"
end


#
# well, helpers...

helpers do

  def get_process_status

    wfid = params[:wfid]

    $engine.process_status(wfid) ||
      throw(:halt, [ 404, "no process '#{wfid}'" ])
  end

  def get_status_and_stack

    pstatus = get_process_status

    pstack = $engine.process_stack pstatus.wfid, true
    class << pstatus
      attr_accessor :process_stack
    end
    pstatus.process_stack = pstack

    pstatus
  end
end

