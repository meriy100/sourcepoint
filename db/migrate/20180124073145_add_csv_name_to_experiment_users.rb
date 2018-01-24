class AddCsvNameToExperimentUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :experiment_users, :csv_name, :string
  end
end
