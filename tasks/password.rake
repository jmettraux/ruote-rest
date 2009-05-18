
#
# tasks for installing / fetching ruote and co
#
namespace :password do

  desc "Generates a password : rake password:generate [smda5|ssha] secret"

  task :generate do

    require 'lib/password'

    clear = ARGV.last
    type = ARGV.size > 2 ? ARGV[-2] : 'smd5'

    puts RuoteRest::Password.send("generate_#{type}", clear)

    exit 0
  end

  desc "Checks password"

  task :check do

    require 'lib/password'

    hashed = ARGV[-2]
    clear = ARGV[-1]

    puts

    if RuoteRest::Password.check_password(hashed, clear)
      puts "matches."
    else
      puts "doesn't match."
    end

    puts

    exit 0
  end
end

