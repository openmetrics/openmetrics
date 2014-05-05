# set paperclip options for storage
#Paperclip::Attachment.default_options[:storage] = :fog
#Paperclip::Attachment.default_options[:fog_credentials] = {:provider => "Local", :local_root => "#{Rails.root}/public"}
#Paperclip::Attachment.default_options[:fog_directory] = ""


# disable paperclips content type detection as it may raise false-positives
# e.g. when uploading a .html file paperclip:
#
# [paperclip] Content Type Spoof: Filename registration_variant_step5.html (["text/html"]), content type discovered from file command: application/xml. See documentation to allow this combination.
#
# Docs say one could map appropriate mime-types like this:
# Paperclip.options[:content_type_mappings] = {
#  :pem => "text/plain"
# }
#
# as we currently only want html/txt file uploads mime type detection is turned of as suggested by http://stackoverflow.com/questions/21912322/ruby-on-rails-paperclip-error

require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
