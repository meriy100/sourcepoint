# == Schema Information
#
# Table name: experiment_lines
#
#  id            :integer          not null, primary key
#  experiment_id :integer          not null
#  number        :integer          not null
#  deleted_line  :boolean          default("0")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :experiment_line do
    experiment_id 1
    number ""
    deleted_line false
  end
end
