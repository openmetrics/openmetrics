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
  has_many :test_projects, -> { includes(:project).order("projects.name ASC")}
  has_many :projects, -> { uniq }, through: :test_projects # http://stackoverflow.com/questions/16569994/deprecation-warning-when-using-has-many-through-uniq-in-rails-4
  accepts_nested_attributes_for :test_projects, allow_destroy: true

  # most recent test plan executions
  def recent_executions(num=5)
    TestExecution.recent_by_test_plan(self.id, num)
  end

  def test_plans_projects
    test_projects = TestProject.where(test_plan_id: self.id)
    ret = []
    if test_projects != nil
      for tp in test_projects
        p = nil
        p = Project.find_by_id tp.project_id
        if p != nil
          ret.push(p)
        end
      end
    end
    return ret
  end
  alias_method :projects, :test_plans_projects


  # Validations
  validates :name, :presence => true, length: {minimum: 3}
  #TODO validate base_url to be there and valid url (?)

end
