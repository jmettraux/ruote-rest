#--
# Copyright (c) 2009, Gonzalo Suarez, Nando Sola.
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
# Made in Spain.
#++

require 'password'


module RuoteRest

  #
  # A ruote-rest user.
  #
  class User < ActiveRecord::Base

    # Returns true if the combination login/password is valid.
    #
    def self.authenticate (login, password)

      user = find_by_login(login)

      user ? RuoteRest::Password.check_password(user.password, password) : false
    end
  end

  #
  # An entry in the 'hosts' table.
  #
  class Host < ActiveRecord::Base

    # Returns true if the remote address is trusted.
    #
    def self.authenticate (remote_addr)

      exists?(:ip => remote_addr, :trusted => true)
    end

    #def valid_host? (host_ip)
    #  info = RuoteRest::Host.find :first, :conditions => ['ip = ?', host_ip]
    #  hour = Time.now.hour
    #  if info
    #    if ((info.from == nil) && (info.to == nil))
    #      true
    #    else
    #      ((info.from.to_i < hour) && (info.to.to_i > hour))   #simple check for time availability. this may be improved as needed...
    #    end
    #  end
    #end
  end

  class HostTables < ActiveRecord::Migration

    def self.up

      create_table :hosts do |t|
        t.column :ip, :string
        t.column :trusted, :string
        t.column :from, :string
        t.column :to, :string
      end
    end

    def self.down

      drop_table :users
    end
  end

  class UserTables < ActiveRecord::Migration

    def self.up

      create_table :users do |t|
        t.column :login, :string
        t.column :name, :string
        t.column :password, :string
        t.column :email, :string
        t.column :created_at, :timestamp
        t.column :updated_at, :timestamp
      end

      add_index :users, :login, :unique => true
      add_index :users, :name
      add_index :users, :email
      add_index :users, :created_at
      add_index :users, :updated_at
    end

    def self.down

      drop_table :users
    end
  end

end

