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

  get '/participants' do

    rrender :participants, RuoteRest.engine.participants
  end

  get '/participants/:pid' do

    rrender :participant, get_participant
  end

  post '/participants' do

    regex, pclass, store_name = rparse(:participant)

    Participants.add(regex, pclass, store_name)

    rrender(:participants, RuoteRest.engine.participants, :status => 201)
  end

  delete '/participants/:pid' do

    pid, part = get_participant

    if pid

      Participants.remove(pid)
      render_reply(200, "participant #{pid} removed")
    else

      render_reply(200, "no participant '#{pid}' to remove")
    end
  end


  #
  # helpers

  helpers do

    def get_participant

      pid = params[:pid]

      if pid

        pid = Rack::Utils.unescape(pid) # no need :)

        regex, part = RuoteRest.engine.participants.find do |pr, pa|
          pr.original_string == pid
        end

        throw(:done, [ 404, "no participant at #{pid}" ]) unless part

        [ regex, part ]

      else

        [ nil, nil ]
      end
    end
  end

end

