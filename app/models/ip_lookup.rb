class IpLookup < ActiveRecord::Base
  include Executable
  include Trackable

  belongs_to :user
  has_one :ip_lookup_result

  # TODO improve for ip adresses, hostname and cidr notation
  validates :target, presence: true, :length => {:minimum => 3}

  def result
    self.ip_lookup_result.result
  end
end
