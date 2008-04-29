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


get "/participants" do

    pid, part = get_participant

    if part
        rrender :participant, part
    else
        rrender :participants, $engine.participant_list
    end
end

get "/participants/:pid" do

    pid, part = get_participant

    rrender :participant, part
end

post "/participants" do

    regex, pclass, store_name = rparse :participant

    $engine.register_participant regex, new_participant(pclass, store_name)

    rrender :participants, $engine.participant_list, :status => 201
end

delete "/participants/:pid" do

    pid, part = get_participant

    $engine.unregister_participant pid

    response.status = 204
end


#
# helpers

helpers do

    def get_participant

        pid = params[:pid]
        pname = params[:pname]

        if pid

            pid = pid.to_i
            part = $engine.participant_list[pid]

            throw :halt, [ 404, "no participant at #{pid}" ] unless part

            [ pid, part ]

        elsif pname

            #part = $engine.get_participant pname
            part = $engine.participant_list.find do |r, p|
                pname.match r
            end

            throw :halt, [ 404, "no participant for name #{pname}" ] unless part

            [ part[1].index, part ]

        else

            [ nil, nil ]
        end
    end

    def new_participant (pclass, store_name)

        throw :halt, [ 400, "cannot create participant of class '#{pclass}'" ] \
            if pclass.match /[\(\) ]/

        pclass = eval(pclass)

        store_name = store_name.strip if store_name
        store_name = nil if store_name == ''

        if pclass == OpenWFE::Extras::ActiveStoreParticipant
            throw :halt, [ 400, "store_name missing" ] unless store_name
            pclass.new store_name
        else
            pclass.new
        end
    end
end

