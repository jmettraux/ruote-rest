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

require 'openwfe/extras/expool/db_history'

module RuoteRest

  get '/history' do

    rrender :history, find_entries(params)
  end

  get '/history/:wfid' do

    rrender :history, find_entries(params)
  end


  helpers do

    def find_entries (params)

      atom = (determine_out_format({}).first == 'atom')

      offset = (params[:offset] || 0).to_i
      offset = 0 if atom

      limit = (params[:limit] || 30).to_i
      limit = 210 if atom

      wfid = params[:wfid]

      event = params[:event]

      order = params[:order] || 'id'
      desc = params[:desc] || 'true'
      order = "#{order} #{desc == 'false' ? 'ASC' : 'DESC'}"
      order = 'id DESC' if atom

      cond = {}
      cond[:wfid] = wfid if wfid
      cond[:event] = event if event

      opts = {
        :offset => offset, :limit => limit, :order => order, :conditions => cond
      }

      total = ActiveRecord::Base::connection.execute(
        'select count(*) from history').fetch_row[0].to_i

      entries = {
        :entries => OpenWFE::Extras::HistoryEntry.find(:all, opts),
        :total => total,
        :offset => offset,
        :limit => limit
      }

      class << entries
        def etag
          md5("#{self[:total]}_#{self[:offset]}_#{self[:limit]}")
        end
      end

      entries
    end
  end

end

