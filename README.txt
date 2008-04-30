
= ruote-rest

A RESTful instance of OpenWFEru (ruote) powered by Sinatra (http://sinatrarb.com)


== getting it

To get Ruote and Ruote-Rest :

    git clone git://github.com/jmettraux/ruote.git
    git clone git://github.com/jmettraux/ruote-rest.git


== dependencies

Depends on Sinatra 0.2.2

    [sudo] gem install -y sinatra


== interface

By default, XML representations will be returned. The 'Accept' header is used to determine which representation the client expects. 

The 'format' query parameter can be used to override that, like in

     GET /processes?format=json

For debugging purposes, you can force to a text/plain content type with 'plain' :

    GET /workitems?format=json&plain=true


=== /processes

GET /processes

    lists all the [business] processes currently running in the engine


POST /processes

    launches a new process instance


GET /processes/{wfid}

    returns the detailed status of a given process instance


GET /processes/{wfid}/representation

    returns the JSON representation of the current process instance tree


DELETE /processes/{wfid}

    cancels a business process instance


=== /expressions

GET /expressions/{wfid}

    returns all the expressions of a business process instance


GET /expressions/{wfid}/{expid}

    returns one expression


GET /expressions/{wfid}/{expid}?format=yaml

    returns the YAML representation of an expression
    (note that using the Accept header is the best way to do that)


PUT /expressions/{wfid}/{expid}

    updates an expression, live. Expects a YAML version of the expression


DELETE /expressions/{wfid}/{expid}

    cancels one expression


=== /workitems

GET /workitems

    lists all the workitems 

GET /workitems/{wid}

    returns a workitem

GET /workitems?wfid=x

    returns all the workitems belonging to a [business] process instance

PUT /workitems/{wid}

    updates a workitem
    If the workitem field '_state' is set to 'proceeded' the workitem will resume its travel in its business process

