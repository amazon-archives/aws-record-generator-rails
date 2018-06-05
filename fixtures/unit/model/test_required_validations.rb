require 'aws-record'
require 'active_model'

class TestModelAutoHkey
  include Aws::Record
  include ActiveModel::Validations

  string_attr :uuid, hash_key: true
  string_attr :title
  string_attr :body

  validates_presence_of :title, :body
end
