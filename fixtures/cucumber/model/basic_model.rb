require 'aws-record'

class BasicModel
  include Aws::Record

  string_attr :id, hash_key: true
  integer_attr :count, range_key: true
end
