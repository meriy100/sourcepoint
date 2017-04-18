# == Schema Information
#
# Table name: lines
#
#  id            :integer          not null, primary key
#  attempt_id    :integer          not null
#  submission_id :integer          not null
#  number        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_lines_on_attempt_id_and_submission_id  (attempt_id,submission_id)
#

FactoryGirl.define do
  factory :line do
    
  end
end
