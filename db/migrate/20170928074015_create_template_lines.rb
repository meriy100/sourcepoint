class CreateTemplateLines < ActiveRecord::Migration[5.0]
  def change
    create_table :template_lines do |t|
      t.references :template, foreign_key: true, index: true, null: false
      t.integer :number, null: false
      t.boolean :deleted_line, null: false, default: true

      t.timestamps
    end
  end
end
