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

