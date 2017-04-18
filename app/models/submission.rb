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
#

class Submission < ApplicationRecord
  has_many :lines
  has_many :attempts, through: :lines
end
