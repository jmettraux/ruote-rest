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
#++


PROCESS_LOOKUP_KEYS = %w{
 value val name variable var v field f recursive to_string
}.collect { |k| k.to_sym }

#
# Returns the statuses of all the process currently running in this ruote_rest
#
get '/processes' do

  lookup_options = PROCESS_LOOKUP_KEYS.inject({}) do |h, k|
    if v = params[k]; h[k] = v; end; h
  end

  #p lookup_options

  processes = application.engine.process_statuses

  if not lookup_options.empty?

    wfids = application.engine.lookup_processes(lookup_options)

    processes = processes.inject({}) do |h, (wfid, ps)|
      h[wfid] = ps if wfids.delete(wfid); h
    end
  end

  rrender(:processes, processes)
end

#
# Launches a business process
#
post '/processes' do

  launchitem = rparse :launchitem

  fei = application.engine.launch(launchitem)

  rrender(
    :fei, fei,
    :status => 201, 'Location' => request.href(:processes, fei.wfid))
end

#
# just return the process instance tree as JSON
#
# (deprecated !)
#
get '/processes/:wfid/representation' do

  rrender(
    :process_tree,
    get_process_status.all_expressions)
end

#
# just return the process instance tree as JSON
#
get '/processes/:wfid/tree' do

  rrender(
    :process_tree,
    get_process_status.all_expressions)
end

#
# Returns the variable of the process (well, the variable set at the
# process level only)
#
get '/processes/:wfid/variables' do

  variables = if params[:wfid] == '0'
    application.engine.get_variables
  else
    get_process_status.variables
  end

  rrender :process_variables, variables
end

#
# Returns the detailed status of a process instance
#
get '/processes/:wfid' do

  rrender :process, get_process_status
end

#
# Updates a process instance (pauses or resumes it).
#
put '/processes/:wfid' do

  pstatus = get_process_status
  process = rparse :process

  if process[:paused]
    application.engine.pause_process pstatus.wfid
  else
    application.engine.resume_process pstatus.wfid
  end

  rrender :process, get_process_status
end

#
# Cancels a process instance
#
delete '/processes/:wfid' do

  wfid = params[:wfid]

  application.engine.cancel_process wfid

  sleep 0.350

  render_ok(request.href(:processes), "process #{wfid} deleted")
end


#
# well, helpers...

helpers do

  def get_process_status

    wfid = params[:wfid]

    application.engine.process_status(wfid) ||
      throw(:done, [ 404, "no process '#{wfid}'" ])
  end
end

