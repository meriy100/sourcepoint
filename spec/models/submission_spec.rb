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
#  experiment_id :integer
#

require 'rails_helper'

RSpec.describe Submission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
