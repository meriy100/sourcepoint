# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  family_name               :string(60)       default("")
#  given_name                :string(60)       default("")
#  role                      :string(20)       default("student")
#
# Indexes
#
#  index_users_on_login  (login) UNIQUE
#

class User < ApplicationRecord
end
