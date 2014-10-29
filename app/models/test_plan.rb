# == Schema Information
#
# Table name: test_plans
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  base_url    :string(255)
#  slug        :string(255)
#

class TestPlan < ActiveRecord::Base
  include Trackable
  include Truncatable
  include Sluggable
  include Qualifiable

  # items
  has_secretary
  has_many :test_plan_items, -> { order('position ASC') }, dependent: :destroy
  has_many :test_items, through: :test_plan_items
  tracks_association :test_plan_items # by rails-secretary gem
  accepts_nested_attributes_for :test_plan_items, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }

  # projects
  has_many :test_projects, -> { with_test_plans } # pass in lambda as scope (see TestProject)
  has_many :projects, through: :test_projects, uniq: true
  accepts_nested_attributes_for :test_projects, allow_destroy: true


  # Validations
  validates :name, :presence => true, length: {minimum: 3}
  #TODO validate base_url to be there and valid url (?)

end
