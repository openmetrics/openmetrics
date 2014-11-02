module Qualified
  extend ActiveSupport::Concern

  included do

    self.inheritance_column = :entity_type

    def text_result
      if self.class.name == 'TestExecution'
        "Todo"
      else
        NotImplementedError
      end

    end

    def quality
      if self.class.name == 'TestExecution'
        Quality.where(test_execution_id: self.id, entity_type: 'TestPlan', entity_id: self.test_plan.id)
      elsif self.class.name == 'TestExecutionItem'
        Quality.where(test_execution_id: self.test_execution.id, entity_type: 'TestItem', entity_id: self.test_item.id)
      elsif self.class.name == 'TestExecutionResult'
        Quality.where(test_execution_id: self.test_execution_id, entity_type: 'TestExecutionResult', entity_id: self.id)
      end
    end
  end

end