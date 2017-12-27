class ChangeAssignmentIdToExperiments < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :experiments, :assignments
    remove_index :experiments, :assignment_id
    remove_column :experiments, :assignment_id
    add_column :experiments, :current_assignment_id, :integer, null: false, index: true
  end
end
