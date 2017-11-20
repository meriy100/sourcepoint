# == Schema Information
#
# Table name: submissions
#
#  id            :integer          not null, primary key
#  submitted     :datetime         not null
#  file1         :binary(65535)
#  messages      :binary(65535)
#  status        :string(255)      default("unchecked"), not null
#  mark          :float(24)
#  comment       :text(65535)
#  assignment_id :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  check_id      :integer
#  template_id   :integer
#

class Submission < ApplicationRecord
  include Concerns::CFile

  has_many :lines, dependent: :destroy
  has_many :attempts, through: :lines
  belongs_to :check, optional: true
  belongs_to :template, optional: true

  before_create :set_submitted

  private

  def set_submitted
    self.submitted = Time.zone.now
  end
end
