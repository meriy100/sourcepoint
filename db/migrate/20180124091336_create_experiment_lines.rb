class CreateExperimentLines < ActiveRecord::Migration[5.0]
  def change
    create_table :experiment_lines do |t|
      t.integer :experiment_id, null: false
      t.integer :number, null: false
      t.boolean :deleted_line, default: false

      t.timestamps
    end
  end
end
