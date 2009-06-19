
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

The last step of the database preparation is loading the authentication settings :

  rake mysql:populate

These settings may be modified by editing tasks/fixtures/host.yml and/or tasks/fixtures/users.yml

To generate a password for a user :

  rake password:generate smd5 my_very_secret_password

or

  rake password:generate ssha my_very_secret_password

The resulting string (something like "{SMD5}HKBKsOPQ1PleLG3KOlmHTWtoNW9HVGxC") can be inserted in the fixture or in the 'password' column database for the given user.


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

MIT


== feedback

user mailing list :        http://groups.google.com/group/openwferu-users
developers mailing list :  http://groups.google.com/group/openwferu-dev

issue tracker :            http://github.com/jmettraux/ruote-rest/issues/

irc :                      irc.freenode.net #ruote

