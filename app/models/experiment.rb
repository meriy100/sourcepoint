# == Schema Information
#
# Table name: experiments
#
#  id                    :integer          not null, primary key
#  file1                 :binary(65535)    not null
#  experiment_user_id    :integer          not null
#  end_at                :datetime
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_assignment_id :integer          not null
#  status                :string(255)
#
# Indexes
#
#  index_experiments_on_experiment_user_id  (experiment_user_id)
#

class Experiment < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Concerns::CFile
  belongs_to :experiment_user
  belongs_to_active_hash :current_assignment

  has_many :submissions

  validates :file1, presence: true

  acts_as_paranoid

  def to_submission
    Submission.new(file1: file1, user_id: experiment_user_id, assignment_id: current_assignment_id, experiment_id: self.id)
  end
end
