class AddIsCheckToTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :templates, :is_check, :boolean, default: false, null: false
  end
end
