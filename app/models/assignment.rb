# == Schema Information
#
# Table name: assignments
#
#  id                 :integer          not null, primary key
#  code               :string(255)      default(""), not null
#  name               :string(255)      default(""), not null
#  opening_time       :datetime         not null
#  preferred_deadline :datetime         not null
#  final_deadline     :datetime         not null
#  files              :integer          default("1"), not null
#  utf_8              :boolean          default("1"), not null
#  warnings_allowed   :integer          default("0"), not null
#  max_file_size      :integer          default("10000"), not null
#  compile            :boolean          default("1"), not null
#  compiler_options   :string(255)      default(""), not null
#  grade_contribution :float(24)        default("1"), not null
#  course_id          :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#

class Assignment < ApplicationRecord
  has_many :attempts
end

