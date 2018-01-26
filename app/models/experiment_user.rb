# == Schema Information
#
# Table name: experiment_users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_at   :datetime
#  csv_name   :string(255)
#

class ExperimentUser < ApplicationRecord
  attr_accessor :csv_data
  acts_as_paranoid
  has_many :experiments

  def csv_data
    $csv_readed ||= CSVData.read_csv
    @csv_data ||= CSVData.where(csv_name: self.csv_name).first
  end
end
