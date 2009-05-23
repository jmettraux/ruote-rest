#--
# Copyright (c) 2009, Gonzalo Suarez, Nando Sola and John Mettraux.
# All rights reserved.
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

      host = find_by_ip(remote_addr)

      return false unless host

      h = Time.now.hour

      return false if host.tfrom && h < host.tfrom.to_i
      return false if host.tto && h > host.tto.to_i

      host.trusted || nil
    end
  end

  class HostTables < ActiveRecord::Migration

    def self.up

      create_table :hosts do |t|
        t.column :ip, :string
        t.column :trusted, :boolean
        t.column :tfrom, :string
        t.column :tto, :string
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

