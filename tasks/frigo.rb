# a gem freeze module
# (couldn't find one [I liked], so wrote it)

# original is at  http://gist.github.com/87639

#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
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
# Made in Japan as opposed to Swiss Made.
#++

require 'fileutils'
require 'rubygems'
require 'rubygems/installer'

module Frigo

  # The 'main' method, given a gem name, fetches it and all its dependencies
  # under a target dir
  #
  # For example :
  #
  #   Frigo.verbose = true
  #   Frigo.fetch_with_dependencies 'rufus-rtm'
  #
  # will create here a subdirectory "vendor" and unpack the gem 'rufus-rtm'
  # and all its dependencies under that "vendor" dir.
  #
  def self.fetch_with_dependencies (gem_name, gem_version=nil, target_dir='vendor')

    if not File.exist?(target_dir)
      #
      # the remote fetcher would create it... do it anyway...
      #
      FileUtils.mkdir(target_dir)
      puts " . created dir #{target_dir}" if @verbose
    end

    deps = determine_dependencies(gem_name, gem_version)
    deps.each { |n, v| fetch(n, v, target_dir) }

    FileUtils.rm_rf("#{target_dir}/cache")

    create_frozen_rb(target_dir)
  end

  private

  @spec_cache = {}

  def self.verbose= (b)
    @verbose = b
  end

  def self.get_dep_and_spec (gem_name, gem_version)

    key = [ gem_name, gem_version ]

    if ds = @spec_cache[key]
      return ds
    end

    dep = Gem::Dependency.new(gem_name, gem_version)
    spec = Gem::SpecFetcher.fetcher.fetch(dep)

    @spec_cache[key] = [ dep, spec ]
  end

  def self.determine_dependencies (gem_name, gem_version=nil, deps=[])

    deps << [ gem_name, gem_version ]

    dep, spec = get_dep_and_spec(gem_name, gem_version)

    spec.first.first.dependencies.each { |d|
      determine_dependencies(
        d.name,
        d.instance_variable_get(:@version_requirement),
        deps)
    }

    deps.uniq
  end

  def self.fetch (gem_name, gem_version, target_dir)

    dep, spec = get_dep_and_spec(gem_name, gem_version)
    spec, source_uri = spec.first

    Dir.chdir(target_dir) do

      gem = "#{spec.full_name}.gem"

      path = Gem::RemoteFetcher.fetcher.download(
        spec, source_uri, File.expand_path('.'))

      puts " .. from #{source_uri} got #{spec.full_name}" if @verbose

      FileUtils.rm_rf(spec.full_name) rescue nil

      Gem::Installer.new(
        "cache/#{gem}",
        :unpack => true,
        :user_install => true # gets rid of the 'gem dir not writable' warning
      ).unpack(spec.full_name)
    end
  end

  def self.create_frozen_rb (target_dir)

    File.open("#{target_dir}/frozen.rb", 'w') do |f|
      f.write(
'''

# require this file to get all the frozen/unpacked gems into the load path
#
# ( created via frigo.rb  http://gist.github.com/87639 )

here = File.expand_path(File.dirname(__FILE__))

Dir.entries(here).select { |p|
  p.match(/^[^\.]/) and File.directory?("#{here}/#{p}/lib")
}.each { |p|
  $:.unshift("#{here}/#{p}/lib")
}

''')
    end
  end
end

if $0 == __FILE__

  args = ARGV[0, 3]

  if args.size == 0 or args.include?('-h') or args.include?('--help')
    puts %{
  ruby frigo.rb {gem} [gem_version] [target_dir]

  fetches the given gem and all its dependencies and unpacks them in the
  target_dir (defaults to vendor/)
    }
    exit 1
  end

  args = [ args.first, nil, args.last ] if args.size == 2

  Frigo.verbose = true
  Frigo.fetch_with_dependencies(*args)
end
