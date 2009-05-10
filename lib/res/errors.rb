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

module RuoteRest

  get '/errors' do

    logs = RuoteRest.engine.get_error_journal.get_error_logs

    errors = logs.values.inject([]) { |a, log| a = a + log }
    errors = errors.sort_by { |err| err.fei.wfid }

    errors.extend(ArrayEtagMixin)

    rrender(:errors, errors)
  end

  get '/errors/:wfid' do

    wfid = params[:wfid]

    errors = RuoteRest.engine.get_error_journal.get_error_log(wfid)

    errors.extend(ArrayEtagMixin)

    rrender(:errors, errors)
  end

  get '/errors/:wfid/:expid' do

    rrender(:error, find_error)
  end

  delete '/errors/:wfid/:expid' do
    replay_error
  end
  post '/errors/:wfid/:expid' do
    replay_error
  end

  #
  # well, helpers...

  helpers do

    def find_error

      wfid = params[:wfid]
      expid = OpenWFE.to_dots(params[:expid])

      errors = RuoteRest.engine.get_error_journal.get_error_log(wfid)

      errors.find { |e| e.fei.expid == expid }
    end

    def replay_error

      error = find_error

      if error

        wi = rparse(:workitem, true)
        atts = wi ? wi.attributes : rparse(:hash, true)
        error.workitem.attributes = atts if atts

        RuoteRest.engine.replay_at_error(error)

        render_ok(request.href(:errors), "error at #{error.href} replayed")
      else

        redirect(request.href(:errors))
      end
    end
  end

end

