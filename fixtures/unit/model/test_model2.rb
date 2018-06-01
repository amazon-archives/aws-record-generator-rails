require 'aws-record'

class TestModel2
  include Aws::Record

  string_attr :uuid, hash_key: true
end
