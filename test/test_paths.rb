
ENV['ruote.environment'] = 'test'

if File.exist?('vendor/frozen.rb')
  require 'vendor/frozen'
elsif File.exist?('vendorf/frozen.rb')
  require 'vendorf/frozen'
end

%w{ lib conf ~/w/ruote/lib ~/w/rufus/rufus-sixjo/lib test }.each do |path|

  path = File.dirname(__FILE__) + '/../' + path unless path[0, 1] == '~'
  path = File.expand_path(path)

  $:.unshift(path) unless $:.include?(path)
end

