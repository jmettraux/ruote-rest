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

  get '/expressions' do

    _erb :expressions_, :layout => :html
  end

  get '/expressions/:wfid' do

    ps = get_process_status

    rrender :expressions, ps.all_expressions
  end

  put '/expressions/:wfid/:expid' do

    e = rparse(:expression)

    RuoteRest.engine.update_expression(e)

    render_reply(200, "expression at #{e.href} updated")
  end

  get '/expressions/:wfid/:expid' do

    rrender(:expression, find_expression)
  end

  get '/expressions/:wfid/:expid/tree' do

    rrender(:expression_tree, find_expression)
  end

  put '/expressions/:wfid/:expid/tree' do

    tree = rparse(:expression_tree)
    e = find_expression

    RuoteRest.engine.update_expression_tree(e, tree)

    render_reply(200, "expression at #{e.href} updated")
  end

  delete '/expressions/:wfid/:expid' do

    e = find_expression

    RuoteRest.engine.cancel_expression e

    render_reply(200, "expression at #{e.href} cancelled (terminated)")
  end


#
# some helper methods

  helpers do

    def find_expression

      wfid = OpenWFE.to_dots(params[:wfid])
      expid = OpenWFE.to_dots(params[:expid])

      env = false

      if expid[-1, 1] == 'e'
        expid = expid[0..-2]
        env = true
      end

      get_process_status.all_expressions.find { |e|
        (e.fei.expid == expid) and (env == e.is_a?(OpenWFE::Environment))
      } or throw :done, [ 404, "no expression #{expid} in process #{wfid}" ]
    end
  end

end

