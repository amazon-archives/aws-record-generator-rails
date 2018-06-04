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

require 'spec_helper'

module AwsRecord
  describe GeneratedAttribute do
    context 'when given valid input' do
      it 'sets the name and type correctly' do
        params = "uuid:int"

        attribute = GeneratedAttribute.parse(params)
        expect(attribute.name).to eq("uuid")
        expect(attribute.type).to eq(:integer_attr)
      end

      it 'properly defaults to string_attr when only a name is provided' do
        params = "uuid"

        attribute = GeneratedAttribute.parse(params)
        expect(attribute.name).to eq("uuid")
        expect(attribute.type).to eq(:string_attr)        
      end

      it 'properly parses all valid types for an attribute' do
        VALID_TYPES = {
          "bool" => :boolean_attr,
          "boolean" => :boolean_attr,
          "date" => :date_attr,
          "datetime" => :datetime_attr,
          "float" => :float_attr,
          "int" => :integer_attr,
          "integer" => :integer_attr,
          "list" => :list_attr,
          "map" => :map_attr,
          "num_set" => :numeric_set_attr,
          "numeric_set" => :numeric_set_attr,
          "nset" => :numeric_set_attr,
          "string_set" => :string_set_attr,
          "s_set" => :string_set_attr,
          "sset" => :string_set_attr,
          "string" => :string_attr
        }

        base_params = "uuid:"
        VALID_TYPES.each do |input, attr_type|
          input_params = "#{base_params}#{input}"

          attribute = GeneratedAttribute.parse(input_params)
          expect(attribute.name).to eq("uuid")
          expect(attribute.type).to eq(attr_type)
        end
      end

      context 'it properly handles attribute options' do

        VALID_OPTIONS = {
          "hkey" => [:hash_key, true],
          "rkey" => [:range_key, true],
          "persist_nil" => [:persist_nil, true],
          "db_attr_name{PostTitle}" => [:database_attribute_name, '"PostTitle"'],
          "ddb_type{BOOL}" => [:dynamodb_type, '"BOOL"'],
          "default_value{9}" => [:default_value, "9"]
        }

        it 'properly handles all valid options' do
          base_params = "uuid:"
          VALID_OPTIONS.each do |opt, parsed_opt|
            input_params = "#{base_params}#{opt}"
  
            attribute = GeneratedAttribute.parse(input_params)
            expect(attribute.name).to eq("uuid")
            expect(attribute.type).to eq(:string_attr)
            expect(attribute.options.to_a).to eq([parsed_opt])
          end
        end

        context 'properly handles using options in combination with one another' do
          it 'allows fields to have a default value and a ddb_type' do
            params = "is_context:bool:persist_nil,ddb_type{BOOL}"

            attribute = GeneratedAttribute.parse(params)
            expect(attribute.name).to eq("is_context")
            expect(attribute.type).to eq(:boolean_attr)
            expect(attribute.options.to_a).to eq([[:persist_nil, true], [:dynamodb_type, '"BOOL"']])
          end

          it 'allows a key field to have a db_attr_name' do
            params  = "uuid:hkey,db_attr_name{PostTitle}"

            attribute = GeneratedAttribute.parse(params)
            expect(attribute.name).to eq("uuid")
            expect(attribute.type).to eq(:string_attr)
            expect(attribute.options.to_a).to eq([[:hash_key, true], [:database_attribute_name, '"PostTitle"']])
          end
        end
      end

      it 'properly infers that a type has not been provided when other options are' do
        params = "uuid:hkey"

        attribute = GeneratedAttribute.parse(params)
        expect(attribute.name).to eq("uuid")
        expect(attribute.type).to eq(:string_attr)
        expect(attribute.options.to_a).to eq([[:hash_key, true]])
      end
    end

    context 'when invalid input is provided' do
      after(:example) do
        GeneratedAttribute.parse_errors.clear
      end
    
      it 'properly detects when an invalid type is provided' do
        params = "uuid:invalid_type:hkey"

        attribute = GeneratedAttribute.parse(params)
        expect(GeneratedAttribute.parse_errors.length).to eq(1)
      end

      it 'properly detects when an invalid opt is provided' do
        params = "uuid:hkey,invalid_opt"

        attribute = GeneratedAttribute.parse(params)
        expect(GeneratedAttribute.parse_errors.length).to eq(1)        
      end

      it 'detects when a field is declared as both an hkey and rkey' do
        params = "uuid:string:hkey,rkey"

        attribute = GeneratedAttribute.parse(params)
        expect(GeneratedAttribute.parse_errors.length).to eq(1)
      end

      it 'detects when a map_attr is declared as a hkey' do
        params = "uuid:map:hkey"

        attribute = GeneratedAttribute.parse(params)
        expect(GeneratedAttribute.parse_errors.length).to eq(1)
      end
    
    end
  end
end
