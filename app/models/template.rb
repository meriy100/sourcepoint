# == Schema Information
#
# Table name: templates
#
#  id                    :integer          not null, primary key
#  file1                 :binary(65535)
#  status                :string(255)
#  user_id               :integer
#  encode_code           :string(255)
#  current_assignment_id :integer
#  assignment_id         :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  is_check              :boolean          default("0"), not null
#

class Template < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Concerns::CFile

  has_many :template_lines
  has_one :submission
  belongs_to_active_hash :current_assignment

  def to_submission
    Submission.new(file1: file1, assignment_id: current_assignment_id, user_id: user_id)
  end
end
