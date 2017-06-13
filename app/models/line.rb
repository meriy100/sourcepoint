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
#  deleted_line  :boolean          default("0")
#
# Indexes
#
#  index_lines_on_attempt_id_and_submission_id  (attempt_id,submission_id)
#

class Line < ApplicationRecord
  belongs_to :attempt
  belongs_to :submission
end
