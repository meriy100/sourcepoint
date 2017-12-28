class AddStatusToExperiments < ActiveRecord::Migration[5.0]
  def change
    add_column :experiments, :status, :string
  end
end
