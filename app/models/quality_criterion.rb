class QualityCriterion < ActiveRecord::Base
  belongs_to :qualifiable, polymorphic: true
  belongs_to :test_plan

  default_scope ->{order('id DESC')}

  def execution_related_objects(test_execution)
    if self.qualifiable_type == 'TestItem'
      if self.position
        TestExecutionItem.where(test_execution_id: test_execution.id, position: self.position)
      else
        TestExecutionItem.where(test_execution_id: test_execution.id)
      end
    elsif self.qualifiable_type == 'TestPlan'
      TestExecution.where(id: test_execution.id)
    end
  end

  def referred_object
    self.qualifiable_type.constantize.find_by id: self.qualifiable_id
  end
end