# == Schema Information
#
# Table name: attempts
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
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_attempts_on_assignment_id  (assignment_id)
#  index_attempts_on_user_id        (user_id)
#

require 'rails_helper'

RSpec.describe Attempt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
