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
#

class Template < ApplicationRecord
  has_many :template_lines
  has_one :submission
end
