module Qualifiable
  extend ActiveSupport::Concern

  included do
    has_many :quality_criteria
    accepts_nested_attributes_for :quality_criteria, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }

    def quality_criteria
      QualityCriterion.where(entity_type: self.entity_class, entity_id: self.id)
    end

    # in context of a TestPlan this should return 'TestPlan',
    # in contrast STI models should return parent's class name, e.g. a TestScript's entity_class returns 'TestItem instead of 'TestScript''
    def entity_class
      self.class.superclass.name == 'ActiveRecord::Base' ? self.class.name : self.class.superclass.name
    end
  end

end