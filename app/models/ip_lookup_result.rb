# == Schema Information
#
# Table name: ip_lookup_results
#
#  id           :integer          not null, primary key
#  ip_lookup_id :integer
#  result       :text
#  created_at   :datetime
#  updated_at   :datetime
#

class IpLookupResult < ActiveRecord::Base
  belongs_to :ip_lookup
end
