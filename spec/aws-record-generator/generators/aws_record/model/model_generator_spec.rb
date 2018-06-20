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

def generate_and_assert_model(name, file_name, *opts)
  opts.unshift name
  @gen_helper.run_generator opts

  generated_file_path = File.join(@gen_helper.destination_root, "app/models/#{file_name}.rb")
  fixture_file_path = File.expand_path("fixtures/unit/model/#{file_name}.rb")
  @gen_helper.assert_file(generated_file_path, fixture_file_path)
end

def generate_and_assert_table_config(name, file_name, *opts)
  opts.unshift name
  @gen_helper.run_generator opts

  generated_file_path = File.join(@gen_helper.destination_root, "db/table_config/#{file_name}_config.rb")
  fixture_file_path = File.expand_path("fixtures/unit/table_config/#{file_name}_config.rb")
  @gen_helper.assert_file(generated_file_path, fixture_file_path)
end

module AwsRecord
  module Generators

    describe ModelGenerator do
      before(:all) do
        @gen_helper = GeneratorTestHelper.new(ModelGenerator, "tmp")
      end
      
      after(:all) do
        @gen_helper.cleanup
      end

      context 'it properly generates basic models' do
        it 'properly creates a model with one field' do
          generate_and_assert_model 'TestModelBasic', "test_model_basic", "uuid:hkey", "--table-config=primary:5-2"
        end

        context 'it creates an hkey when one is not provided' do
          it 'creates a uuid hkey when no fields are provided' do
            generate_and_assert_model 'TestModelFieldsAbsentAutoUuid', "test_model_fields_absent_auto_uuid", "--table-config=primary:5-2"
          end

          it 'creates a uuid hkey when fields are provided but an hkey is not' do
            generate_and_assert_model "TestModelFieldsPresentAutoUuid", "test_model_fields_present_auto_uuid", "name", "--table-config=primary:5-2"
          end

          it 'adds an hkey option to the uuid attribute if it is present, but no other field is an hkey' do
            generate_and_assert_model "TestModelAutoHkey", "test_model_auto_hkey", "uuid", "--table-config=primary:5-2"
          end
        end

        it 'allows the user to disable mutation tracking' do
          generate_and_assert_model "TestModelMutTracking", "test_model_mut_tracking", "uuid:hkey", "--disable-mutation-tracking", "--table-config=primary:5-2"
        end

        it 'allows the user to generate models with multiple fields and options' do
          generate_and_assert_model "TestModelComplex", "test_model_complex", "forum_uuid:hkey", "post_id:rkey", "author_username", "post_title", "post_body", "tags:sset:default_value{Set.new}", "created_at:datetime:db_attr_name{PostCreatedAtTime}", "moderation:boolean:default_value{false}", "--table-config=primary:5-2"
        end

        it 'enforces the uniqueness of field names' do
          expect {
            @gen_helper.run_generator ["TestModel_Err", "uuid:hkey", "uuid", "--table-config=primary:5-2"]
          }.to raise_error(SystemExit)

          @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/test_model_err.rb"))
        end

        it 'enforces the uniqueness of field db_attribute_name across fields' do
          expect {
            @gen_helper.run_generator ["TestModel_Err", "uuid:hkey", "long_title:db_attr_name{uuid}", "--table-config=primary:5-2"]
          }.to raise_error(SystemExit)

          @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/test_model_err.rb"))
        end

        it 'raises an ArgumentError if any of the fields have errors' do
          expect {
            @gen_helper.run_generator ["TestModel_Err", "uuid:invalid_type:hkey", "uuid:hkey,invalid_opt", "uuid:string:hkey,rkey", "uuid:map:hkey", "--table-config=primary:5-2"]
          }.to raise_error(SystemExit)
        end

      end

      context 'properly generated table configs based on input' do
        it 'throws an error when no table config attributes are provided' do
          expect {
            generate_and_assert_table_config "TableConfigTestModel1", "table_config_test_model1", "uuid:hkey"
          }.to raise_error(SystemExit)
        end

        it 'properly generates the table_config when primary r/w units are provided' do
          generate_and_assert_table_config "TableConfigTestModel2", "table_config_test_model2", "--table-config=primary:20-10"
        end
      end

      context 'it properly handles generating secondary indexes' do
        context 'gsis are properly inserted into models' do
          it 'generates a gsi with only rkey' do
            generate_and_assert_model "TestModelGSIBasic", "test_model_gsi_basic", "gsi_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "--table-config=primary:5-2", "SecondaryIndex:5-2"
          end

          it 'generates a gsi with rkey and hkey' do
            generate_and_assert_model "TestModelGSIKeys", "test_model_gsi_keys", "gsi_hkey", "gsi_rkey", "--gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}", "--table-config=primary:5-2", "SecondaryIndex:5-2"
          end

          it 'generates a model with multiple gsis' do 
            generate_and_assert_model "TestModelGSIMult", "test_model_gsi_mult", "gsi_hkey", "gsi2_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "SecondaryIndex2:hkey{gsi2_hkey}", "--table-config=primary:5-2", "SecondaryIndex:5-2", "SecondaryIndex2:5-2"
          end

          it 'enforces that a given hkey is a valid field in the model' do
            expect {
              @gen_helper.run_generator ["TestModel_Err", "gsi_rkey", "--gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}", "--table-config=primary:5-2", "SecondaryIndex:5-2"]
            }.to raise_error(SystemExit)

            @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/test_model_err.rb"))
          end

          it 'enforces that a given rkey is a valid field in the model' do
            expect {
              @gen_helper.run_generator ["TestModel_Err", "gsi_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}", "--table-config=primary:5-2", "SecondaryIndex:5-2"]
            }.to raise_error(SystemExit)

            @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/test_model_err.rb"))
          end
        end

        context 'gsis are properly added into table_configs' do
          it 'throws an error when no r/w unit info is provided' do
            expect {
                generate_and_assert_table_config "TestTableConfigGSIBasic", "test_table_config_gsi_basic", "gsi_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "--table-config=primary:5-2"
            }.to raise_error(SystemExit)
          end

          it 'the user can provide r/w values for a table config' do
            generate_and_assert_table_config "TestTableConfigGSIProvided", "test_table_config_gsi_provided", "gsi_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "--table-config=primary:5-2", "SecondaryIndex:50-100"
          end

          it 'generates a table_config with multiple gsis' do 
            generate_and_assert_table_config "TestTable_ConfigGSIMult", "test_table_config_gsi_mult", "gsi_hkey", "gsi2_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "SecondaryIndex2:hkey{gsi2_hkey}", "--table-config=primary:5-2", "SecondaryIndex:10-11", "SecondaryIndex2:40-20"
          end

          it 'errors out when the user provides r/w values for a secondary index that does not exist' do
            expect {
              generate_and_assert_table_config "TestModel_Err", "test_table_config_gsi_provided", "gsi_hkey", "--gsi=SecondaryIndex:hkey{gsi_hkey}", "--table-config=primary:5-2", "SecondaryIndexes:50-100"
            }.to raise_error(SystemExit)
          end
        end
      end

      context 'it allows users to automatically add timestamps to their model' do
        it 'creates timestamps when the flag is enabled' do
          generate_and_assert_model "TestModelTimestamps", "test_model_timestamps", "--timestamps", "--table_config=primary:5-2"
        end
      end

      context 'it allows use of basic ActiveModel validations' do
        it 'allows specification of required validations' do
          generate_and_assert_model "TestRequiredValidations", "test_required_validations", "title", "body", "--required=title", "body", "--table_config=primary:5-2"
        end

        it 'allows specification of length validations' do
          generate_and_assert_model "TestLengthValidations", "test_length_validations", "title", "body", "--length-validations=title:5-10", "body:100-250", "--table_config=primary:5-2"
        end

        it 'allows specification of a combination of validations' do
          generate_and_assert_model "TestValidations", "test_validations", "title", "body", "--required=title", "body", "--length-validations=title:5-10", "body:100-250", "--table_config=primary:5-2"
        end
      end

      it 'it allows the generation of scaffold helpers' do
        generate_and_assert_model "TestScaffoldHelpers", "test_scaffold_helpers", "--table_config=primary:5-2", "--scaffold"
      end

    end
  end
end
