class Checkmigration < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :check_id, :integer
    create_table :checks do |t|
      t.boolean :valiable_order, default: false, null: false
      t.boolean :blacket, default: false, null: false
      t.boolean :success, default: false, null: false
      t.boolean :near, default: false, null: false
      t.boolean :complete, default: false, null: false
      t.text :remarks
    end
  end
end
