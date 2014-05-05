class Upload < ActiveRecord::Base
  # see https://github.com/thoughtbot/paperclip for options
  has_attached_file :uploaded_file

  # check content type (allow text/*)
  validates_attachment_content_type :uploaded_file, :content_type => /\Atext\/.*\Z/
end
