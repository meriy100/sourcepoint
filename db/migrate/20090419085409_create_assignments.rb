class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.string   :code, :null => false, :default => ''  # added after scaffold
      t.string   :name, :null => false, :default => ''
      t.datetime :opening_time, :null => false
      t.datetime :preferred_deadline, :null => false
      t.datetime :final_deadline, :null => false
      t.integer  :files, :null => false, :default => 1
      t.boolean  :utf_8, :null => false, :default => true
      t.integer  :warnings_allowed, :null => false, :default => 0
      t.integer  :max_file_size, :null => false, :default => 10_000
      t.boolean  :compile, :null => false, :default => true
      t.string   :compiler_options, :null => false, :default => ''
      t.float    :grade_contribution, :null => false, :default => 1.0  # added after scaffold
      t.integer  :course_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
