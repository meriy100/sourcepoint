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

require 'rails_helper'

RSpec.describe TemplateLine, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
