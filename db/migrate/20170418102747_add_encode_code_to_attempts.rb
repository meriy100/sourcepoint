class AddEncodeCodeToAttempts < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :encode_code, :text
  end
end
