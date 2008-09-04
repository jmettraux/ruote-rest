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

require 'openwfe/extras/expool/dbhistory'


get "/history" do

  rrender :history, find_entries(params)
end

get "/history/:wfid" do

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
      :offset => offset, :limit => limit, :order => order, :conditions => cond }

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
