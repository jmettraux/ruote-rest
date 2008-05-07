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

require 'openwfe/worklist/storeparticipant'
require 'openwfe/extras/participants/activeparticipants'


#
# methods for adding/removing/loading participants
#
module Participants

    def self.load_all

        File.open filename do |f|
            YAML.load f
        end
    end

    def self.save (participants)

        File.open filename, 'w' do |f|
            f.puts YAML.dump(participants)
        end
    end

    def self.add (pregex, classname, *args)

        register pregex, classname, *args

        participants = load_all

        pregex = pregex.source if pregex.is_a?(Regexp)

        participants << [ pregex, classname, *args ]

        save participants
    end

    def self.register (pregex, classname, args)

        clazz = classname.constantize # thanks activesupport

        participant = if args
            clazz.new args
        else
            clazz.new
        end

        $engine.register_participant pregex, participant
    end

    def self.remove (pregex)

        part = $engine.list_participants.find do |pr, pa|
            pr == pregex
        end

        $engine.list_participants.delete part
    end

    def self.init_all

        ps = load_all

        ps.each do |pregex, classname, args|
            register pregex, classname, args
        end
    end

    #
    # As the name implies...
    #
    def self.reset_participants_test_yaml
    end

    protected

        def self.filename
            "conf/participants_#{Sinatra.application.options.env}.yaml"
        end

end

