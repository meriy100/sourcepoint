class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.datetime :submitted, null: false
      t.binary :file1
      t.binary :messages
      t.string :status, null: false, default: 'unchecked'
      t.float :mark
      t.text :comment
      t.integer :assignment_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
