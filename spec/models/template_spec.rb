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

require 'rails_helper'

RSpec.describe Template, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
