require 'aws-record'

class TestModel4
  include Aws::Record

  string_attr :uuid, hash_key = true
end
