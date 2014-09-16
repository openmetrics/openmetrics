module Qualified
  extend ActiveSupport::Concern

  included do

    self.inheritance_column = :entity_type

    def quality
      if self.class.name == 'TestExecution'
        Quality.where(test_execution_id: self.id, entity_type: 'TestPlan', entity_id: self.test_plan.id)
      elsif self.class.name == 'TestExecutionItem'
        Quality.where(test_execution_id: self.test_execution.id, entity_type: 'TestItem', entity_id: self.test_item.id)
      end
    end
  end

end