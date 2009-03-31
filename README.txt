
= ruote-rest

A RESTful instance of OpenWFEru (ruote) powered by Rack (http://rack.rubyforge.org/)


== getting it

Get it from GitHub or download a prepackaged release at http://rubyforge.org/frs/?group_id=2609 (and jump to '== preparing it')

To get Ruote and Ruote-Rest :

  git clone git://github.com/jmettraux/ruote-rest.git

Then

  cd ruote-rest 
  rake ruote:install

to install the Ruote (OpenWFEru) workflow engine and its dependencies (in a vendor/ subdirectory). Alternatively, you could do 

  rake ruote:gem_install

to get the dependencies as gems.

If you want to grab the gem and freeze them under vendorf/ do :

  rake ruote:install_freeze


== preparing it

To prepare the development database

  rake mysql:setup

Expects a mysql db with a 'root' admin account with sufficient access rights. 
It will create a database named "ruoterest_development".

(
To prepare the test database

  rake mysql:setup stage=test

To prepare the dev database with the admin 'toto'

  rake mysql:setup dbadmin=toto
)


== starting it

  ruby lib/start.rb


Then head to

  http://localhost:4567/

(
to start it on port 3333 :

  ruby lib/start.rb -p 3333
)

it will lead you to the "service document" with links to all the resources/
collection that make ruote-rest.


== interface

Just navigate the interface with your browser, everything is there.


== configuration

conf/db.rb

  database configuration

conf/engine.rb

  engine configuration

conf/participants.rb
conf/participants_development.yaml

  participants configuration, the yaml file holds the list of 
  'active participants' (the worklist in fact).

conf/auth.rb

  authentication filters, contains an HTTP basic authentication example
  and a "whitelist" authentication example.


== license

BSD


== feedback

user mailing list :        http://groups.google.com/group/openwferu-users
developers mailing list :  http://groups.google.com/group/openwferu-dev

issue tracker :            http://rubyforge.org/tracker/?atid=10023&group_id=2609&func=browse

irc :                      irc.freenode.net #ruote

