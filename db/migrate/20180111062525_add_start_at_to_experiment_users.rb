class AddStartAtToExperimentUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :experiment_users, :start_at, :datetime
  end
end
