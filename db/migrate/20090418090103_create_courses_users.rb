class CreateCoursesUsers < ActiveRecord::Migration
  def self.up
    create_table :courses_users, :id => false do |t|
      t.integer :course_id, :null => false
      t.integer :user_id, :null => false
    end
    
    add_index :courses_users, [:course_id, :user_id], :unique => true
  end

  def self.down
    remove_index :courses_users, :column => [:course_id, :user_id]
    drop_table :courses_users
  end
end
