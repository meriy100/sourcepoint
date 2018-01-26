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

class ExperimentLine < ApplicationRecord
  belongs_to :experiment

  def ==(other)
    if other.class == Line
      [other.number, other.deleted_line] == [number, deleted_line]
    else
      super
    end
  end
end
