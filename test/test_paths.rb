
ENV['ruote.environment'] = 'test'

[ 'lib', 'conf', 'vendor', '~/ruote/lib', 'test' ].each do |path|

  path = File.dirname(__FILE__) + '/../' + path unless path[0, 1] == '~'
  path = File.expand_path(path)

  $:.unshift(path) unless $:.include?(path)
end

