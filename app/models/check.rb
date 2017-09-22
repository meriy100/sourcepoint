# == Schema Information
#
# Table name: checks
#
#  id             :integer          not null, primary key
#  valiable_order :boolean          default("0"), not null
#  blacket        :boolean          default("0"), not null
#  success        :boolean          default("0"), not null
#  near           :boolean          default("0"), not null
#  complete       :boolean          default("0"), not null
#  remarks        :text(65535)
#

class Check < ApplicationRecord
  has_one :submission
end
