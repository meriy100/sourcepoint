class CreateFirstAdmin < ActiveRecord::Migration
  def self.up
    down
    first_admin = User.new()
    first_admin.login = 'admin'
    first_admin.email = 'rpcsr_admin@example.org'
    first_admin.password = 'guessMe'
    first_admin.password_confirmation = 'guessMe'
    first_admin.given_name = '-Administrator-'
    first_admin.family_name = '-Admin-'
    first_admin.role = 'admin'
    first_admin.save!
  end

  def self.down
    User.delete_all
  end
end
