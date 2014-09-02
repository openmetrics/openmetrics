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

require 'test_helper'

class RunningServiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
