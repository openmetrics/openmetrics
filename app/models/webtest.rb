# == Schema Information
#
# Table name: webtests
#
#  id          :integer          not null, primary key
#  description :text
#  base_url    :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Webtest < ActiveRecord::Base
end
