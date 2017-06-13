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

require 'rails_helper'

RSpec.describe Line, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
