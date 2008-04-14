
= ruote-rest

A RESTful instance of OpenWFEru (ruote) powered by Sinatra (http://sinatrarb.com)


== getting it

To get Ruote and Ruote-Rest :

    git clone git://github.com/jmettraux/ruote.git
    git clone git://github.com/jmettraux/ruote-rest.git


To get Sinatra :

    git clone git://github.com/jmettraux/sinatra.git


== interface

=== /processes

GET /processes

    lists all the [business] processes currently running in the engine


POST /processes

    launches a new process instance


GET /processes/{wfid}

    returns the detailed status of a given process instance


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

