# == Schema Information
#
# Table name: experiment_lines
#
#  id            :integer          not null, primary key
#  experiment_id :integer          not null
#  number        :integer          not null
#  deleted_line  :boolean          default("0")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe ExperimentLine, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
