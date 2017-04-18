class AddIndicesToAssignments < ActiveRecord::Migration
  def self.up
    add_index :attempts, :assignment_id
    add_index :attempts, :user_id
  end

  def self.down
    remove_index :attempts, :user_id
    remove_index :attempts, :assignment_id
  end
end
