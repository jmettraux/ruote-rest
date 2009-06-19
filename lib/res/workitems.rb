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


module RuoteRest

  get '/workitems' do

    rrender :workitems, find_workitems
  end

  get '/workitems/:wfid' do

    rrender :workitems, find_workitems
  end

  get '/workitems/:wfid/:expid' do

    rrender :workitem, find_workitem
  end

  put '/workitems/:wfid/:expid' do

    wi = find_workitem

    owi = rparse(:workitem)
    owi.fei = wi.full_fei

    #owi.attributes.delete('_uri')
    state = owi.attributes.delete('_state')

    if state == 'proceeded'

      RuoteRest.engine.reply(owi)
      wi.destroy

      render_reply(200, "workitem at #{owi.href} proceeded")
    else

      # TODO : notify HTML clients of the update ? flash.notice ?

      wi.replace_fields(owi.attributes)

      render_reply(200, "workitem at #{owi.href} updated")
    end
  end

  # The "http listener"
  #
  # redirects any workitem coming here to the engine.
  #
  post '/workitems' do

    wi = rparse(:workitem)

    RuoteRest.engine.reply(wi)

    render_reply(200, "workitem #{wi.fei.wfid} #{wi.fei.expid}proceeded")
  end

  #
  # helpers

  helpers do

    def find_workitem

      wfid = OpenWFE.to_dots(params[:wfid])
      expid = OpenWFE.to_dots(params[:expid])

      OpenWFE::Extras::ArWorkitem.find_by_wfid_and_expid(wfid, expid) ||
        throw(:done, [ 404, "no workitem #{params[:wfid]}/#{params[:expid]}" ])
    end

    def find_workitems

      p = params[:participant]
      sn = get_store_names
      wfid = params[:wfid]
      q = params[:q]

      workitems = if p
        OpenWFE::Extras::ArWorkitem.find_all_by_participant_name(p)
      elsif q
        OpenWFE::Extras::ArWorkitem.search(q, sn)
      elsif sn
        OpenWFE::Extras::ArWorkitem.find_in_stores(sn)
      elsif wfid
        OpenWFE::Extras::ArWorkitem.find_all_by_wfid(wfid)
      else
        OpenWFE::Extras::ArWorkitem.find :all
      end

      workitems = workitems.sort_by { |wi| wi.id }

      workitems.extend(ArrayEtagMixin)

      workitems
    end

    # Returns an array of store names or nil, if the parameter 'store'
    # is not passed.
    # Expects a comma separated list of store names
    #
    def get_store_names

      sname = params[:store]
      sname ? sname.split(',') : nil
    end
  end

end

