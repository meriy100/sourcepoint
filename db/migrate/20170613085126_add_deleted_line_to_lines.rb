class AddDeletedLineToLines < ActiveRecord::Migration[5.0]
  def change
    add_column :lines, :deleted_line, :boolean, default: false
  end
end
