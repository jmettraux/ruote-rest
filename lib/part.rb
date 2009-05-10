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


require 'openwfe/participants/store_participants'
require 'openwfe/extras/participants/ar_participants'


#
# methods for adding/removing/loading participants
#
module Participants

  def self.load_all
    if File.exists?( @filename )
      File.open @filename do |f|
        YAML.load f
      end
    else
      []
    end
  end

  def self.save (participants)

    File.open @filename, 'w' do |f|
      f.puts YAML.dump(participants)
    end
  end

  def self.add (pregex, classname, *args)

    register(pregex, classname, *args)

    participants = load_all

    pregex = pregex.source if pregex.is_a?(Regexp)

    participants << [ pregex, classname, *args ]

    save participants
  end

  def self.register (pregex, classname, args)

    clazz = classname.constantize # thanks activesupport

    participant = args ? clazz.new(*args) : clazz.new
      # patch by Nick Petrella

    @engine.register_participant(pregex, participant)
  end

  def self.remove (pregex)

    part = @engine.participants.find do |pr, pa|
      pr == pregex
    end

    @engine.participants.delete part
  end

  def self.init_all (engine, filename)

    @engine = engine
    @filename = filename

    ps = load_all

    ps.each do |pregex, classname, args|
      register(pregex, classname, args)
    end
  end

end

