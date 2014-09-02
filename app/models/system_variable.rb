# == Schema Information
#
# Table name: system_variables
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  value     :string(255)
#  system_id :integer
#

class SystemVariable < ActiveRecord::Base
  belongs_to :system
end
