# == Schema Information
#
# Table name: uploads
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime
#  updated_at                 :datetime
#  uploaded_file_file_name    :string(255)
#  uploaded_file_content_type :string(255)
#  uploaded_file_file_size    :integer
#  uploaded_file_updated_at   :datetime
#

class Upload < ActiveRecord::Base
  # see https://github.com/thoughtbot/paperclip for options
  has_attached_file :uploaded_file

  # check content type (allow text/* & image/* files)
  validates_attachment_content_type :uploaded_file, :content_type => /\A(text|image)\/.*\Z/
end
