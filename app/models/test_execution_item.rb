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
  belongs_to :test_item
  belongs_to :test_execution

  # TODO add simple test if there is any occurance in self's and self.test_item's markup of String ENV: e.g. ENV['foo'] = 'bar' or doWhatever(ENV['foo'])
  def provides_input?
    true
  end

  # virtual attribute execution time in millisecond precision, calculated from started_at and finished_at
  def duration
    return nil if self.started_at.nil? or self.finished_at.nil?
    (self.finished_at - self.started_at).round(3)
  end

end
