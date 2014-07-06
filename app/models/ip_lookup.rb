class IpLookup < ActiveRecord::Base
  include Executable

  belongs_to :user
  has_one :ip_lookup_result

  # TODO improve for ip adresses, hostname and cidr notation
  validates :target, presence: true, :length => {:minimum => 3}
end
