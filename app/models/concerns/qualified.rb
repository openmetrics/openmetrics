module Qualified
  extend ActiveSupport::Concern

  included do

    self.inheritance_column = :entity_type

    def text_result
      if self.class.name == 'TestExecution'
        QUALITY_STATUS[self.result.exitstatus] unless self.result.exitstatus.nil?
      else
        NotImplementedError
      end
    end

    def image_result
      if self.class.name == 'TestExecution'
        QUALITY_STATUS[self.result.exitstatus] unless self.result.exitstatus.nil?
        if self.result.exitstatus == 0
          return '<span class="fa fa-check-square-o text-success"></span>'
        elsif self.result.exitstatus == 5
          return '<span class="fa fa-exclamation-circle text-warning"></span>'
        elsif self.result.exitstatus == 10
          return '<span class="fa fa-exclamation-triangle text-danger"></span>'
        end
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
        self.test_execution.quality.flatten | self.test_execution.test_execution_items.collect{ |tpi| tpi.quality }.flatten
      end
    end

    # quality objects with quality_criterion not set
    def overall_quality
      if self.class.name == 'TestExecutionItem'
        Quality.where(test_execution_id: self.test_execution.id, entity_type: 'TestExecutionItem', entity_id: self.id, quality_criterion_id: nil)
      end
    end

    def quality_criteria
      if self.class.name == 'TestExecution'
        QualityCriterion.where(qualifiable_type: 'TestPlan', qualifiable_id: self.test_plan.id) | self.test_execution_items.collect{ |tpi| tpi.criteria }.flatten
      elsif self.class.name == 'TestExecutionItem'
        QualityCriterion.where(qualifiable_type: 'TestItem', qualifiable_id: self.test_item.id, position: self.test_plan_item.position, test_plan_id: self.test_execution.test_plan_id)
      end
    end
    alias_method :related_criteria, :quality_criteria
    alias_method :criteria, :quality_criteria


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