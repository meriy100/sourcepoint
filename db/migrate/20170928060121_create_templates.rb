class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.binary :file1
      t.string :status
      t.integer :user_id
      t.string :encode_code
      t.integer :current_assignment_id
      t.integer :assignment_id

      t.timestamps
    end
  end
end
