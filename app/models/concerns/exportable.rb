module Exportable
  extend ActiveSupport::Concern

  included do
    def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |this_model|
          csv << this_model.attributes.values_at(*column_names)
        end
      end
    end
  end

end