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
#
# Indexes
#
#  index_attempts_on_assignment_id          (assignment_id)
#  index_attempts_on_current_assignment_id  (current_assignment_id)
#  index_attempts_on_user_id                (user_id)
#

class Attempt < ApplicationRecord
  belongs_to :assignment
  has_many :liens
  attr_accessor :dist
end
