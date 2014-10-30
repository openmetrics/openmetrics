class Project < ActiveRecord::Base
  belongs_to :creator, foreign_key: 'creator_id', class_name: 'User'
  has_many :test_projects
  has_many :test_plans, through: :test_projects

  # Scopes
  default_scope { order(:name => :asc) }
end
