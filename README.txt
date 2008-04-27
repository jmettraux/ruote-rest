
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


DELETE /expressions/{wfid}/{expid}

    cancels one expression


=== /workitems

GET /workitems.xml?wfid={wfid}
GET /workitems/{wfid}/{expid} .... (refine that)

