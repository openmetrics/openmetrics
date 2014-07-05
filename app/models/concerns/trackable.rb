module Trackable
  extend ActiveSupport::Concern

  included do
    #include PublicActivity::Model
    #tracked owner: ->(controller, model) { controller && controller.current_user}
    include PublicActivity::Common
  end

end