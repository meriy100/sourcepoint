# this is actually not a creation, but a renaming with addition
class CreateEnrollments < ActiveRecord::Migration
  def self.up
    rename_table :courses_users, :enrollments

    add_column :enrollments, :id, :primary_key # see https://thinkwhere.wordpress.com/2009/05/09/adding-a-primary-key-id-to-table-in-rails/
    add_column :enrollments, :seat, :string, :default => ''
    
    add_timestamps :enrollments
  end

  def self.down
    remove_timestamps :enrollments

    remove_column :enrollments, :seat
    remove_column :enrollments, :id

    rename_table :enrollments, :courses_users
  end
end
