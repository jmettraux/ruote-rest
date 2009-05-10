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

  PROCESS_LOOKUP_KEYS = %w{
    value val name variable var v field f
  }.collect { |k| k.to_sym }

  # Returns the statuses of all the process currently running in this ruote_rest
  #
  get '/processes' do

    lookup_options = PROCESS_LOOKUP_KEYS.inject({}) do |h, k|
      if v = params[k]; h[k] = v; end; h
    end

    lookup_options[:recursive] = true if has?(:recursive)
    lookup_options[:to_string] = true if has?(:to_string)

    processes = RuoteRest.engine.process_statuses

    if not lookup_options.empty?

      wfids = RuoteRest.engine.lookup_processes(lookup_options)

      processes = processes.inject({}) do |h, (wfid, ps)|
        h[wfid] = ps if wfids.delete(wfid); h
      end
    end

    rrender(:processes, processes)
  end

  # Launches a business process
  #
  post '/processes' do

    launchitem = rparse(:launchitem)

    fei = RuoteRest.engine.launch(launchitem)

    rrender(
      :fei, fei,
      :status => 201, 'Location' => request.href(:processes, fei.wfid))
  end

  # Just return the process instance tree as JSON
  #
  # (deprecated !)
  #
  get '/processes/:wfid/representation' do

    rrender(
      :process_tree,
      get_process_status.all_expressions)
  end

  # Just return the process instance tree as JSON
  #
  get '/processes/:wfid/tree' do

    rrender(
      :process_tree,
      get_process_status.all_expressions)
  end

  # Returns the variable of the process (well, the variable set at the
  # process level only)
  #
  get '/processes/:wfid/variables' do

    variables = if params[:wfid] == '0'
      RuoteRest.engine.get_variables
    else
      get_process_status.variables
    end

    rrender :process_variables, variables
  end

  # Returns the detailed status of a process instance
  #
  get '/processes/:wfid' do

    rrender :process, get_process_status
  end

  # Updates a process instance (pauses or resumes it).
  #
  put '/processes/:wfid' do

    pstatus = get_process_status
    process = rparse :process

    if process[:paused]
      RuoteRest.engine.pause_process pstatus.wfid
    else
      RuoteRest.engine.resume_process pstatus.wfid
    end

    rrender :process, get_process_status
  end

  # Cancels a process instance
  #
  delete '/processes/:wfid' do

    wfid = params[:wfid]

    RuoteRest.engine.cancel_process(wfid)

    sleep 0.350

    render_reply(200, "process #{wfid} deleted")
  end


  #
  # well, helpers...

  helpers do

    def get_process_status

      wfid = params[:wfid]

      RuoteRest.engine.process_status(wfid) ||
        throw(:done, [ 404, "no process '#{wfid}'" ])
    end

    def has? (key)
      v = params[key]
      v == 'true' or v == '1'
    end
  end

end

