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


get "/workitems" do

  rrender :workitems, find_workitems
end

get "/workitems/:wid" do

  rrender :workitem, find_workitem
end

put "/workitems/:wid" do

  wi = find_workitem

  owi = rparse :workitem

  owi.attributes.delete '_uri'
  state = owi.attributes.delete '_state'

  if state == 'proceeded'

    owi.fei = wi.full_fei

    $engine.reply owi
    wi.destroy

    header 'Location' => request.link(:workitems)
    rrender :workitems, find_workitems
  else

    wi.replace_fields owi.attributes
    rrender :workitem, wi
  end
end


#
# helpers

helpers do

  def find_workitem

    wid = params[:wid]

    begin
      OpenWFE::Extras::Workitem.find wid
    rescue Exception => e
      throw :halt, [ 404, "no workitem with id #{wid}" ]
    end
  end

  def find_workitems

    #pname = params[:pname]
    sn = get_store_names
    wfid = params[:wfid]
    q = params[:q]

    workitems = if q
      OpenWFE::Extras::Workitem.search q, sn
    elsif sn
      OpenWFE::Extras::Workitem.find_in_stores sn
    elsif wfid
      OpenWFE::Extras::Workitem.find_all_by_wfid wfid
    else
      OpenWFE::Extras::Workitem.find :all
    end

    workitems.sort_by { |wi| wi.id }
  end

  #
  # Returns an array of store names or nil, if the parameter 'store'
  # is not passed.
  # Expects a comma separated list of store names
  #
  def get_store_names

    sname = params[:store]
    return nil unless sname
    sname.split ","
  end
end

