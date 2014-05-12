module Pollable
  extend ActiveSupport::Concern

  included do
    after_save :get_status_updates

    # scopes based on status, see TEST_EXECUTION_STATUS in test_execution_constants.rb
    scope :scheduled, -> { where(status: 10) }
    scope :prepared, -> { where(status: 20) }
    scope :started, -> { where(status: 30) }
    scope :finished, -> { where(status: 40) }
    #scope :enlightened -> { where('my_models.status != ?', 'confused') }
  end

  def get_status_updates
    status
  end
end