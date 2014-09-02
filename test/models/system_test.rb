# == Schema Information
#
# Table name: systems
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  fqdn                     :string(255)
#  operating_system         :string(255)
#  operating_system_flavour :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  slug                     :string(255)
#  description              :text
#  cidr                     :string(255)
#  sshuser                  :string(255)
#

require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
