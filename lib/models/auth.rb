
module OpenWFE
  module Extras

    class User < ActiveRecord::Base
    end

    class Host < ActiveRecord::Base
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
end
