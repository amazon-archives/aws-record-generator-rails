require 'aws-record'

class TestModel1
  include Aws::Record

  string_attr :forum_uuid, hash_key: true    
  string_attr :post_id, range_key: true    
  string_attr :author_username    
  string_attr :post_title    
  string_attr :post_body    
  string_attr :tags, default_value: Set.new    
  datetime_attr :created_at, database_attribute_name: "PostCreatedAtTime"    
  string_attr :moderation, default_value: false
end
