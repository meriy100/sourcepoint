class CreateLines < ActiveRecord::Migration[5.0]
  def change
    create_table :lines do |t|
      t.integer :attempt_id, null: false
      t.integer :submission_id, null: false
      t.integer :number, null: false
      t.timestamps
    end
    add_index :lines, [:attempt_id, :submission_id], using: :btree
  end
end
