# == Schema Information
#
# Table name: experiment_users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_at   :datetime
#

FactoryGirl.define do
  factory :experiment_user do
    name "MyString"
    deleted_at ""
  end
end
