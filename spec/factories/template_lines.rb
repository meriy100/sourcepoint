# == Schema Information
#
# Table name: template_lines
#
#  id           :integer          not null, primary key
#  template_id  :integer          not null
#  number       :integer          not null
#  deleted_line :boolean          default("0"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_template_lines_on_template_id  (template_id)
#

FactoryGirl.define do
  factory :template_line do
    template nil
    number 1
    deleted_line false
  end
end
