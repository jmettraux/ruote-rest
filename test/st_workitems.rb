
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Tue Apr 29 18:07:46 JST 2008
#



#require 'test/unit'

require 'rubygems'
require 'sinatra'
require 'sinatra/test/unit'

require 'ruote_rest.rb'
require 'testbase'


class StWorkitemsTest < Test::Unit::TestCase

    include TestBase

    include Sinatra::Builder
    include Sinatra::RenderingHelpers
    

    def test_0
    end

end

