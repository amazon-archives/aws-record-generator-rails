require 'aws-record'

class TestModel5
  include Aws::Record
  disable_mutation_tracking

  string_attr :uuid, hash_key: true
end
