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

def generate_and_assert_model(name, *opts)
  opts.unshift name
  @gen_helper.run_generator opts

  generated_file_path = File.join(@gen_helper.destination_root, "app/models/#{name}.rb")
  fixture_file_path = File.expand_path("fixtures/unit/model/#{name}.rb")
  @gen_helper.assert_file(generated_file_path, fixture_file_path)
end

module AwsRecord

  describe ModelGenerator do
    before(:all) do
      @gen_helper = AwsRecord::GeneratorTestHelper.new(ModelGenerator, "tmp")
    end
    
    after(:all) do
      @gen_helper.cleanup
    end

    context 'it properly generates basic models' do
      it 'properly creates a model with one field' do
        generate_and_assert_model 'TestModel1', "uuid:hkey"
      end

      context 'it creates an hkey when one is not provided' do
        it 'creates a uuid hkey when no fields are provided' do
          generate_and_assert_model 'TestModel2'
        end

        it 'creates a uuid hkey when fields are provided but an hkey is not' do
          generate_and_assert_model "TestModel3", "name"
        end

        it 'adds an hkey option to the uuid attribute if it is present, but no other field is an hkey' do
          generate_and_assert_model "TestModel4", "uuid"
        end
      end

      it 'allows the user to disable mutation tracking' do
        generate_and_assert_model "TestModel5", "uuid:hkey", "--disable-mutation-tracking"
      end

      it 'allows the user to generate models with multiple fields and options' do
        generate_and_assert_model "TestModel6", "forum_uuid:hkey post_id:rkey author_username post_title post_body tags:sset:default_value{Set.new} created_at:datetime:d_attr_name{PostCreatedAtTime} moderation:boolean:default_value{false}"
      end

      it 'enforces the uniqueness of field names' do
        expect {
          @gen_helper.run_generator ["TestModel_Err", "uuid:hkey uuid"]
        }.to raise_error(ArgumentError)

        @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/TestModel_Err.rb"))
      end

      it 'enforces the uniqueness of field db_attribute_name across fields' do
        expect {
          @gen_helper.run_generator ["TestModel_Err", "uuid:hkey long_title:db_attr_name{uuid}"]
        }.to raise_error(ArgumentError)

        @gen_helper.assert_not_file(File.expand_path("fixtures/unit/model/TestModel_Err.rb"))
      end

    end
  end
end
