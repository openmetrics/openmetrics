module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable_on :labels
  end

end