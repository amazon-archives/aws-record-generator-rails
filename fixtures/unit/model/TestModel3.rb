require 'aws-record'

class TestModel3
  include Aws::Record

  string_attr :uuid, hash_key = true
  string_attr :name
end
