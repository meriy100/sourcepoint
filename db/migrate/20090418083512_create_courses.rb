class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name, :null => false
      t.text :description, :default => '', :null => false
      t.datetime :enrollment_deadline
      t.boolean :visible, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
