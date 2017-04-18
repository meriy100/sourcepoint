class SplitName < ActiveRecord::Migration
  def self.up
    remove_column :users, :name
    add_column :users, :family_name, :string, :limit => 60, :default => '', :null => true
    add_column :users, :given_name, :string, :limit => 60, :default => '', :null => true
  end

  def self.down
    add_column :users, :name, :string, :limit => 100, :default => '', :null => true
    remove_column :users, :family_name
    remove_column :users, :given_name
  end
end
