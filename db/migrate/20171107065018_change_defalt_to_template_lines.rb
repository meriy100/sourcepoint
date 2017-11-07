class ChangeDefaltToTemplateLines < ActiveRecord::Migration[5.0]
  def up
    change_column :template_lines, :deleted_line, :boolean, null: false, default: false
  end

  def down
  end
end
