# == Schema Information
#
# Table name: attempts
#
#  id                    :integer          not null, primary key
#  submitted             :datetime         not null
#  file1                 :binary(65535)
#  messages              :binary(65535)
#  status                :string(255)      default("unchecked"), not null
#  mark                  :float(24)
#  comment               :text(65535)
#  assignment_id         :integer          not null
#  user_id               :integer          not null
#  created_at            :datetime
#  updated_at            :datetime
#  encode_code           :text(65535)
#  current_assignment_id :integer
#  deleted_at            :datetime
#
# Indexes
#
#  index_attempts_on_assignment_id          (assignment_id)
#  index_attempts_on_current_assignment_id  (current_assignment_id)
#  index_attempts_on_user_id                (user_id)
#

class Attempt < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Concerns::CFile

  belongs_to :assignment
  has_many :liens
  belongs_to :current_assignment
  attr_accessor :dist

  acts_as_paranoid

  def to_submission
    Submission.new(file1: file1, messages: messages, assignment_id: current_assignment_id, user_id: user_id)
  end
end
