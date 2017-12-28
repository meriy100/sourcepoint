# == Schema Information
#
# Table name: experiments
#
#  id                    :integer          not null, primary key
#  file1                 :binary(65535)    not null
#  experiment_user_id    :integer          not null
#  end_at                :datetime
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_assignment_id :integer          not null
#  status                :string(255)
#
# Indexes
#
#  index_experiments_on_experiment_user_id  (experiment_user_id)
#

require 'rails_helper'

RSpec.describe Experiment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
