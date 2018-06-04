## AWS Record Generator

Allows the generation of aws-record models using a Rails generator

## Links of Interest

* aws-record Documentation(https://docs.aws.amazon.com/awssdkrubyrecord/api/)
* DynamoDB Developers Guide(https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)

## Installation

## Usage

You can either invoke the generator by calling `rails g aws_record:model ...` or you can configure `aws-record-generator` to be your project's default orm in `config/application.rb` by:

```
config.generators do |g|
  g.orm             :aws_record
end
```

which will result in aws_record being invoked when you call `rails g model ...`

The syntax for creating an aws-record model follows:

`rails g aws_record:model field_name:type:opts... --disable_mutation_tracking --table-config=read:NUM_READ write:NUM_WRITE`

The possible field types are:

Field Name | aws-record attribute type
---------------- | -------------
`bool \| boolean` | :boolean_attr
`date` | :date_attr
`datetime` | :datetime_attr
`float` | :float_attr
`int \| integer` | :integer_attr
`list` | :list_attr
`map` | :map_attr
`num_set \| numeric_set \| nset` | :numeric_set_attr
`string_set \| s_set \| sset` | :string_set_attr
`string` | :string_attr


If a type is not provided `aws-record-generator` will assume the field is of type `:string_attr`

Additionally a number of options may be attached as a comma seperated list to the field:

Option Name | aws-record option
---------------- | -------------
`hkey` | marks an attribute as a hash_key
`rkey` | marks an attribute as a range_key
`persist_nil` | will persist nil values in a attribute
`db_attr_name{NAME}` | sets a secondary name for an attribute, these must be unique across attribute names
`ddb_type{S\|N\|B\|BOOL\|SS\|NS\|BS\|M\|L}` | sets the dynamo_db_type for an attribute
`default_value{Object}` | sets the default value for an attribute

The standard rules apply for using options in a model. Additional reading can be found here(#links-of-interest)

An example invocation is:
`rails g aws_record:model Forum forum_uuid:hkey post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new} created_at:datetime:db_attr_name{PostCreatedAtTime} moderation:boolean:default_value{false}`

Which results in the following files being generated:

```ruby

# app/models/forum.rb

require 'aws-record'

class Forum
  include Aws::Record

  string_attr :forum_uuid, hash_key: true
  string_attr :post_id, range_key: true
  string_attr :author_username
  string_attr :post_title
  string_attr :post_body
  string_set_attr :tags, default_value: Set.new
  datetime_attr :created_at, database_attribute_name: "PostCreatedAtTime"
  boolean_attr :moderation, default_value: false
end

```
```ruby

# db/table_config/forum_config.rb

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class Forum

      t.read_capacity_units 5
      t.write_capacity_units 2
    end
  end
end

```

Additionally the first time the generator is run, it places a rake task in `lib/tasks/table_config_migrate_task.rake` which runs all of the table configs in `db/table_config` and can be called by `rails aws_record:migrate`

## License

This library is licensed under the Apache 2.0 License. 
