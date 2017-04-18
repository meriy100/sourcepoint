class AddRoleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string, :limit => 20, :default => 'student', :null => true
  end

  def self.down
    remove_column :users, :role
  end
end
