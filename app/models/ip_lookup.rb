# == Schema Information
#
# Table name: ip_lookups
#
#  id          :integer          not null, primary key
#  target      :string(255)
#  scanresult  :text
#  job_id      :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  started_at  :datetime
#  finished_at :datetime
#  status      :integer
#

class IpLookup < ActiveRecord::Base
  include Executable
  include Trackable

  belongs_to :user
  has_one :ip_lookup_result

  # TODO improve for ip adresses, hostname and cidr notation
  validates :target, presence: true, :length => {:minimum => 3}
end
