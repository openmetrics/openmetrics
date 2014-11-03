class AddTestPlanIdToQualityCriterion < ActiveRecord::Migration
  def change
    add_column :quality_criteria, :test_plan_id, :integer
  end
end
