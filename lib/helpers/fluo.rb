#--
# Copyright (c) 2008-2009, John Mettraux, OpenWFE.org
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
#
# Made in Japan.
#++


module RuoteRest

  helpers do

    def render_fluo_head
      %{
<div>
  <div style="float: left; width: 63%;">
      }
    end

    def render_fluo_foot (wfid, expid=nil, workitems=[])

      rep = if wfid == nil
        "<script>var proc_rep = null;</script>"
      elsif wfid.is_a?(Array)
        "<script>var proc_rep = #{OpenWFE::Json.encode( wfid )};</script>"
      else
        "<script src=\"/processes/#{wfid}/tree?format=js&var=proc_rep\"></script>"
      end

      hl = expid ? "\nFluoCan.highlight('fluo', '#{expid}');" : ""

      %{
  </div>

  <script src="/js/fluo-json.js"></script>
  <script src="/js/fluo-can.js"></script>

  <div style="float: right;">

  <!-- fluo -->

    <canvas id="fluo" width="50" height="50"></canvas>
    #{rep}
    <script>
      if (proc_rep) {
        FluoCan.renderFlow('fluo', proc_rep, {'workitems': #{Array(workitems).inspect}});
        FluoCan.crop('fluo');#{hl}
      }
    </script>

    <div style="text-align: right;">
      <br/>
      <a id="dataurl_link" href="">graph data url</a>
      <script>
        var a = document.getElementById('dataurl_link');
        a.href = document.getElementById('fluo').toDataURL();
      </script>
    </div>

  </div>
  <div style="clear: both;"></div>
</div>
      }
    end

  end

end

