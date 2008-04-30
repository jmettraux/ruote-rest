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
# Reopening Rack::Request to add some convenience methods
#
class Rack::Request

    #
    #     request.link(:expressions, "abc", "0_0_1")
    #     #=> "http://example.org:4567/expressions/abc/0_0_1"
    #
    def link (*args)

        base = "#{scheme}://#{host}"

        if (scheme == 'https' && port != 443) || 
           (scheme == 'http' && port != 80)

           base << ":#{port}"
        end

        base + "/" + args.collect {|a| a.to_s }.join("/")
    end
end

#
# reopening some OpenWFE classes to add some link magic
#

class OpenWFE::FlowExpressionId

    #
    # Returns the relative link to the expression pointed at by this
    # FlowExpressionId.
    #
    #     fei.link 
    #         # => "/expressions/{wfid}/{expid}"
    #
    #     fei.link(request)
    #         # => "http://host:port/expressions/{wfid}/{expid}"
    #
    #     fei.link(request, 'smurfs')
    #         # => "http://host:port/smurfs/{wfid}/{expid}"
    #
    #     fei.link(nil, 'smurfs')
    #         # => "smurfs/{wfid}/{expid}"
    #
    def link (req=nil, resource_name='expressions')

        ei = swapdots self.expid

        return req.link(resource_name, wfid, ei) if req

        env = self.expname == "environment" ? "e" : ""

        "/#{resource_name}/#{wfid}/#{ei}#{env}"
    end
end

class OpenWFE::FlowExpression

    #
    # a shortcut for
    #
    #     self.fei.link(req)
    #
    def link (req=nil)

        self.fei.link(req)
    end
end

module OpenWFE::Participant

    #
    # adding an 'index' field
    #
    attr_accessor :index

    #
    # Returns the ruote-rest link for this participant.
    # If a request is passed, the link will be absolute.
    #
    def link (request=nil)

        return request.link(:participants, index) if request

        "/participants/#{index}"
    end
end

class OpenWFE::Engine

    #
    # Making sure that each participant has an index field
    #
    def participant_list

        l = []
        self.list_participants.each_with_index do |part, i|
            part[1].index = i
            l << part
        end
        l
    end
end

class OpenWFE::InFlowWorkItem

    #
    # Returns the 'ruote-rest' link for this workitem
    #
    def link (request=nil)

        return request.link(:workitems, db_id) if request

        "/workitems/#{db_id}"
    end
end

