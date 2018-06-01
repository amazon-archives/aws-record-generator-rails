require 'aws-record'

class TestModel1
  include Aws::Record

  string_attr :uuid, hash_key: true
end
