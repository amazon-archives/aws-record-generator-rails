require 'aws-record'

class TestModel1
  include Aws::Record
  disable_mutation_tracking

  string_attr :uuid, hash_key = true
end
