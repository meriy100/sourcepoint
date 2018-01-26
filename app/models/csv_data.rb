require 'csv'

class CSVData < ActiveHash::Base
  fields :created_at, :csv_name, :clang_level, :use_langs, :assignment_level, :hilight_usefull, :hilight_understand, :experiment_understand, :debug_way, :remarks

  def self.read_csv
    CSV.read('ankart.csv')[1..-1].each do |data|
      attributes = [:created_at, :csv_name, :clang_level, :use_langs, :assignment_level, :hilight_usefull, :hilight_understand, :experiment_understand, :debug_way, :remarks]
        .zip(data)
        .each_with_object({}) do |key_value, o|
        o[key_value.first] = key_value.last
      end
      add attributes
    end
  end
end
