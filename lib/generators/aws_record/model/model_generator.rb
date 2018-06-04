# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License is
# located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions
# and limitations under the License.

require 'rails/generators'
require 'aws-record-generator'

module AwsRecord
  class ModelGenerator < Rails::Generators::NamedBase
    DEFAULT_READ_UNITS = 5
    DEFAULT_WRITE_UNITS = 2

    source_root File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:opts] field[:type][:opts]..."
    check_class_collision

    class_option :disable_mutation_tracking, type: :boolean, banner: "--disable-mutation-tracking"
    class_option :table_config, type: :hash, default: {}, banner: "--table-config=read:NUM_READ write:NUM_WRITE"

    attr_accessor :primary_read_units, :primary_write_units

    def create_model
      template "model.rb", File.join("app/models", class_path, "#{file_name}.rb")
    end

    def create_table_config
      template "table_config.rb", File.join("db/table_config", class_path, "#{file_name}_config.rb")
    end

    def create_table_config_migrate_task
      rake_task_path = File.join("lib", "tasks", "table_config_migrate_task.rake")
      if !File.exist? rake_task_path
        template "table_config_migrate_task.rake", rake_task_path
      end
    end

    private

    def initialize(args, *options)
      super
      parse_table_config!
    end

    def parse_attributes!

      parse_errors = []

      self.attributes = (attributes || []).map do |attr|
        begin
          GeneratedAttribute.parse(attr)
        rescue ArgumentError => e
          parse_errors << e
        end
      end

      if !parse_errors.empty?
        puts "The following errors were encountered while trying to parse the given attributes"
        puts parse_errors

        raise ArgumentError.new("Please fix the attribute errors before proceeding.")
      end

      ensure_hkey
      ensure_unique_fields
    end

    def ensure_unique_fields
      used_names = Set.new
      duplicate_fields = []

      self.attributes.each do |attr|

        if used_names.include? attr.name 
          duplicate_fields << [:attribute, attr.name]
        end
        used_names.add attr.name

        if attr.options.key? :database_attribute_name
          raw_db_attr_name = attr.options[:database_attribute_name].delete('"') # db attribute names are wrapped with " to make template generation easier

          if used_names.include? raw_db_attr_name
            duplicate_fields << [:database_attribute_name, raw_db_attr_name]
          end

          used_names.add raw_db_attr_name
        end
      end

      if !duplicate_fields.empty?
        duplicate_fields.each do |invalid_attr|
          puts "Found duplicated name: #{invalid_attr[1]}, in #{invalid_attr[0]}"
        end

        raise ArgumentError.new("Please remove duplicated names before proceeding")
      end
    end

    def ensure_hkey
      uuid_member = nil
      self.attributes.each do |attr|
        if attr.options.key? :hash_key
          return
        end

        if attr.name.include? "uuid"
          uuid_member = attr
        end
      end

      if uuid_member
        uuid_member.options[:hash_key] = true
      else
        self.attributes.unshift GeneratedAttribute.parse("uuid:hkey")
      end
    end

    def mutation_tracking_disabled?
      options['disable_mutation_tracking']
    end

    def parse_table_config!
      if !options['table_config'].key? 'read'
        @primary_read_units = DEFAULT_READ_UNITS
      else
        @primary_read_units = options['table_config']['read']
      end

      if !options['table_config'].key? 'write'
        @primary_write_units = DEFAULT_WRITE_UNITS
      else
        @primary_write_units = options['table_config']['write']
      end
    end
  end
end
