class AddPositionToQualityCriterion < ActiveRecord::Migration
  def change
    add_column :quality_criteria, :position, :integer
  end
end
