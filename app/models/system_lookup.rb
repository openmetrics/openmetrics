class SystemLookup < ActiveRecord::Base
  include Executable
  include Trackable

  belongs_to :user
  belongs_to :system
  has_one :system_lookup_result

  strip_attributes

  def result
    self.system_lookup_result.result
  end
end
