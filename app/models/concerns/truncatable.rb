module Truncatable
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  included do

    def truncated_description(length=24, needle=nil, sanatize=true)
      raise NoMethodError unless self.respond_to?('description')
      description = strip_tags(self.description)
      if needle
        start_at = 0
        wrap_around = 12
        end_at = description.length
        str_pos = description.index(/#{needle}/i)
        unless str_pos.nil?
          if  str_pos-wrap_around > 0
            start_at = str_pos-wrap_around
          end
          if str_pos+wrap_around < description.length
            end_at = str_pos + wrap_around
          end
        end

        cutted_desc = description[start_at..end_at]
        # puts "First match: #{str_pos}"
        # puts "Start at: #{start_at}"
        # puts "End at: #{end_at}"
        # puts "Length: #{description.length}"
        # puts "Cutted: #{cutted_desc}"
        # puts "New Length: #{cutted_desc.length}"
        cutted_desc
      else
        truncate(self.description, length)
      end

    end
  end

end