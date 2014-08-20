module Sluggable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :name, use: :slugged
  end

end