class CreateExperiments < ActiveRecord::Migration[5.0]
  def change
    create_table :experiments do |t|
      t.binary :file1, null: false
      t.references :assignment, foreign_key: true, null: false
      t.references :experiment_user, foreign_key: true, null: false
      t.datetime :end_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
