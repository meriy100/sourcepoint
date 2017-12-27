# == Schema Information
#
# Table name: experiments
#
#  id                 :integer          not null, primary key
#  file1              :binary(65535)    not null
#  assignment_id      :integer          not null
#  experiment_user_id :integer          not null
#  end_at             :datetime
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_experiments_on_assignment_id       (assignment_id)
#  index_experiments_on_experiment_user_id  (experiment_user_id)
#

FactoryGirl.define do
  factory :experiment do
    file1 ""
    assignment nil
    experiment_user nil
    end_at "2017-12-27 17:03:29"
    deleted_at "2017-12-27 17:03:29"
  end
end
