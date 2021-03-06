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

class TemplateLine < ApplicationRecord
  belongs_to :template

  def ==(other)
    if other.class == Line
      [other.number, other.deleted_line] == [number, deleted_line]
    else
      super
    end
  end
end
