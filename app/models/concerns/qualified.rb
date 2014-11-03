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
        Quality.where(test_execution_id: self.id, entity_type: 'TestExecution', entity_id: self.id)
      elsif self.class.name == 'TestExecutionItem'
        Quality.where(test_execution_id: self.test_execution.id, entity_type: 'TestExecutionItem', entity_id: self.id)
      elsif self.class.name == 'TestExecutionResult'
        Quality.where(test_execution_id: self.test_execution_id, entity_type: 'TestExecutionResult', entity_id: self.id)
      end
    end


    # def quality_criteria
    #   # test plan and test items criteria for test execution
    #   if self.class.name == 'TestExecution'
    #     QualityCriterion.where(qualifiable_id: self.test_plan.id, qualifiable_type: 'TestPlan')
    #   elsif self.class.name == 'TestExecutionItem'
    #     QualityCriterion.where(qualifiable_id: self.test_item.id, qualifiable_type: 'TestItem')
    #   end
    # end
  end

end