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

    source_root File.expand_path('../templates', __FILE__)
    argument :attributes, type: :array, default: [], banner: "field[:type][:opts] field[:type][:opts]..."
    check_class_collision

    class_option :disable_mutation_tracking, type: :boolean, banner: "--disable-mutation-tracking"
    class_option :timestamps, type: :boolean, banner: "--timestamps"
    class_option :table_config, type: :hash, default: {}, banner: "--table-config=[primary:READ..WRITE] [gsi1:READ..WRITE]..."
    class_option :gsi, type: :array, default: [], banner: "--gsi=name:hkey{field_name}[,rkey{field_name},proj_type{ALL|KEYS_ONLY|INCLUDE}]..."

    attr_accessor :primary_read_units, :primary_write_units, :gsi_rw_units, :gsis

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
      @parse_errors = []
      
      super
      ensure_unique_fields
      ensure_hkey
      parse_gsis!
      parse_table_config!

      if !@parse_errors.empty?
        puts "The following errors were encountered while trying to parse the given attributes"
        puts @parse_errors

        raise ArgumentError.new("Please fix the errors before proceeding.")
      end
    end

    def parse_attributes!

      self.attributes = (attributes || []).map do |attr|
        begin
          GeneratedAttribute.parse(attr)
        rescue ArgumentError => e
          @parse_errors << e
          next
        end
      end
      self.attributes = self.attributes.compact

      if options['timestamps']
        self.attributes << GeneratedAttribute.parse("created:datetime:default_value{Time.now}")
        self.attributes << GeneratedAttribute.parse("updated:datetime:default_value{Time.now}")
      end
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
          @parse_errors << ArgumentError.new("Found duplicated field name: #{invalid_attr[1]}, in attribute#{invalid_attr[0]}")
        end
      end
    end

    def ensure_hkey
      uuid_member = nil
      hkey_member = nil
      rkey_member = nil

      self.attributes.each do |attr|
        if attr.options.key? :hash_key
          if hkey_member
            @parse_errors << ArgumentError.new("Redefinition of hash_key attr: #{attr.name}, original declaration of hash_key on: #{hkey_member.name}")
            next
          end

          hkey_member = attr
        elsif attr.options.key? :range_key
          if rkey_member
            @parse_errors << ArgumentError.new("Redefinition of range_key attr: #{attr.name}, original declaration of range_key on: #{hkey_member.name}")
            next
          end

          rkey_member = attr
        end

        if attr.name.include? "uuid"
          uuid_member = attr
        end
      end

      if !hkey_member
        if uuid_member
          uuid_member.options[:hash_key] = true
        else
          self.attributes.unshift GeneratedAttribute.parse("uuid:hkey")
        end
      end
    end

    def mutation_tracking_disabled?
      options['disable_mutation_tracking']
    end

    def parse_table_config!
      @primary_read_units, @primary_write_units = parse_rw_units("primary")

      @gsi_rw_units = @gsis.map { |idx|
        [idx.name, parse_rw_units(idx.name)]
      }.to_h

      options['table_config'].each do |config, rw_units|
        if config == "primary"
          next
        else
          gsi = @gsis.select { |idx| idx.name == config}

          if gsi.empty?
            @parse_errors << ArgumentError.new("Could not find a gsi declaration for #{config}")
          end
        end
      end
    end

    def parse_rw_units(name)
      if !options['table_config'].key? name
        @parse_errors << ArgumentError.new("Please provide a table_config definition for #{name}")
      else
        rw_units = options['table_config'][name]
        return rw_units.gsub(/[,.-]/, ':').split(':').reject { |s| s.empty? }
      end
    end

    def parse_gsis!
      @gsis = (options['gsi'] || []).map do |raw_idx|
        begin
          idx = SecondaryIndex.parse(raw_idx)

          attributes = self.attributes.select { |attr| attr.name == idx.hash_key}
          if attributes.empty?
            @parse_errors << ArgumentError.new("Could not find attribute #{idx.hash_key} for gsi #{idx.name} hkey")
            next
          end

          if idx.range_key
            attributes = self.attributes.select { |attr| attr.name == idx.range_key}
            if attributes.empty?
              @parse_errors << ArgumentError.new("Could not find attribute #{idx.range_key} for gsi #{idx.name} rkey")
              next
            end
          end

          idx
        rescue ArgumentError => e
          @parse_errors << e
          next
        end
      end
      
      @gsis = @gsis.compact
    end
  end
end
