class AddDeletedAtToAttempts < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :deleted_at, :datetime
  end
end
