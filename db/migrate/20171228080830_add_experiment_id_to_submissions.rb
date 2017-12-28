class AddExperimentIdToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :experiment_id, :integer
  end
end
