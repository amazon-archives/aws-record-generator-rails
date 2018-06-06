require 'aws-record'

class BasicSecondaryIndexModel
  include Aws::Record

  string_attr :id, hash_key: true
  integer_attr :count, range_key: true
  string_attr :title

  global_secondary_index(
    :secondary_idx,
    hash_key: :title,
    projection: {
      projection_type: "ALL"
    }
  )
end
