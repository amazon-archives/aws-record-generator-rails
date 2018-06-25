require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class Dog

      t.read_capacity_units 11
      t.write_capacity_units 4
    end
  end
end
