class AddCurrentAssignmentIdToAttempts < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :current_assignment_id, :integer
    add_index :attempts, :current_assignment_id, using: :btree
  end
end
