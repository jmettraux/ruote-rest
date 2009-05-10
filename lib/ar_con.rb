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

require 'active_record'

module RuoteRest

  def self.establish_ar_connection (env)

    base = defined?(RUOTE_BASE_DIR) ? RUOTE_BASE_DIR : '.'

    configuration = YAML.load_file(
      File.join(base, 'conf', 'database.yaml')
    )[env]

    raise(ArgumentError.new(
      "No database configuration for #{application.environment} environment!")
    ) if configuration.nil?

    ActiveRecord::Base.establish_connection(
      :adapter => configuration['adapter'],
      :database => configuration['database'],
      :username => configuration['username'],
      :password => configuration['password'],
      :host => configuration['host'],
      :encoding => configuration['encoding'],
      :pool => 30
    )
  end
end

