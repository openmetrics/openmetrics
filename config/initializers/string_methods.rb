require 'json'

class String

  # returns acronym for some specific Strings, e.g. 'Service' will become 'SVC', also see inflections.rb
  def to_acr
    case self
      when 'Project'
        'P'
      when 'RunningService'
        'RS'
      when 'Service'
        'SVC'
      when 'System'
        'SYS'
      when 'TestCase'
        'TC'
      when 'TestExecution'
        'TE'
      when 'TestExecutionItem'
        'TEI'
      when 'TestPlan'
        'TP'
      when 'TestScript'
        'TS'
      else
        self
    end
  end
  alias_method :to_acronym, :to_acr

  def is_number?
    true if Float(self) rescue false
  end
  alias_method :is_numeric?, :is_number?

  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end
end