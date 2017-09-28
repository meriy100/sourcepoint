class AddTemplateIdSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :template_id, :integer, index: true
  end
end
