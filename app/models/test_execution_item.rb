# == Schema Information
#
# Table name: test_execution_items
#
#  id                :integer          not null, primary key
#  format            :string(255)
#  markup            :text
#  test_execution_id :integer
#  exitstatus        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  test_item_id      :integer
#  output            :text
#  status            :integer
#  error             :text
#  started_at        :datetime
#  finished_at       :datetime
#  executable        :text
#

class TestExecutionItem < ActiveRecord::Base
  include Pollable
  include Qualified
  belongs_to :test_item
  belongs_to :test_execution

  def test_plan_item
    TestPlanItem.find_by test_plan_id: self.test_execution.test_plan_id, test_item_id: self.test_item_id, position: self.position
  end

  def working_dir
    File.dirname(self.executable)
  end

  def provides_input?
    if self.test_item.format == 'selenese'
      self.test_item.markup.include?('<td>store</td>')
    elsif self.test_item.format == 'ruby' and self.test_item.provides_random_input?
      true
    else
      false
    end
  end
  alias_method :input_provided?, :provides_input?

  def provided_input
    if self.test_item.format == 'selenese'
      WebtestAutomagick::selenese_extract_input(self.test_item.markup)
    elsif self.test_item.format == 'ruby'
      if self.test_item.provides_random_input?
        e_basename = File.basename(self.executable)
        e_dirname = File.dirname(self.executable)
        env_infile = "#{e_dirname}/in/#{e_basename.gsub(/\.rb/, '.env')}"
        WebtestAutomagick::ruby_extract_input_from_file(env_infile)
      else
        WebtestAutomagick::ruby_extract_input(self.markup)
      end
    else
      nil
    end
  end

  def requires_input?
    # translated selenium-webdriver markup makes use of ENV['foo'] notation
    if self.test_item.format == 'selenese' && self.format == 'ruby'
      # we want to match references ENV['foo'], but not their assignments ENV['foo'] = 'bar'
      tmp_matches = self.markup.scan(/ENV\[.*\].+/)
      if tmp_matches.any?
        tmp_matches.each do |match|
          return false if match.scan(/=/).any?
        end
      end
      return true
    end
    false
  end
  alias_method :input_required?, :requires_input?

  # virtual attribute execution time in millisecond precision, calculated from started_at and finished_at
  def duration
    return nil if self.started_at.nil? or self.finished_at.nil?
    (self.finished_at - self.started_at).round(3)
  end

end
