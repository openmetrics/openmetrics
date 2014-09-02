# == Schema Information
#
# Table name: running_services
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  type        :string(255)
#  system_id   :integer
#  service_id  :integer
#  description :text
#  fqdn        :string(255)
#

class RunningService < ActiveRecord::Base
  belongs_to :system
  belongs_to :service

  # disable STI
  # type column shouldnt be needed at all, but it could be used to have easy access to type (as String)
  # otherwise ActiveRecord::SubclassNotFound: Invalid single-table inheritance type: HttpService is not a subclass of RunningService
  self.inheritance_column = :_type_disabled
end
