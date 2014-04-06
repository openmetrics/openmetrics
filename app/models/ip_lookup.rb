class IpLookup < ActiveRecord::Base
  belongs_to :user
  # TODO improve for ip adresses, hostname and cidr notation
  validates :target, presence: true, :length => {:minimum => 3}
end
