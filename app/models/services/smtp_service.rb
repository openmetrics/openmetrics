# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  type         :string(255)
#  description  :text
#  daemon_name  :string(255)
#  init_name    :string(255)
#  systemd_name :string(255)
#  fqdn         :string(255)
#

class SmtpService < Service
end