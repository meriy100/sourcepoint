# == Schema Information
#
# Table name: experiment_users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ExperimentUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
