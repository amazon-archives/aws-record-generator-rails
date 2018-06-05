require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class BasicSecondaryIndexModel

      t.read_capacity_units 11
      t.write_capacity_units 4

      t.global_secondary_index(:secondary_idx) do |i|
        i.read_capacity_units 10
        i.write_capacity_units 5
      end
    end
  end
end
