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

require 'securerandom'
require 'aws-record-generator'

Before do
  @gen_helper = AwsRecord::Generators::GeneratorTestHelper.new(AwsRecord::Generators::ModelGenerator, "tmp")
  @file_prefix = nil
end

After("@modelgen") do
  @gen_helper.cleanup
end

When("we run the rails command line with:") do |cmd|
  if cmd.start_with?('g aws_record:model') || cmd.start_with?('g aws_record:scaffold')
    @model_name = cmd.split(' ')[2]
    @table_name = "#{@model_name}_#{SecureRandom.uuid}"
    cmd << " --table-name=#{@table_name}"

    begin
      @client.describe_table(table_name: @table_name)
      abort("#{@table_name} already exists in DynamoDB")
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException; end
  end

  @gen_helper.run_in_test_app cmd
end

Then("a {string} should be generated matching fixture at: {string}") do |generated_type, fixture_file_path|
  file_name = fixture_file_path.split('/')[-1]
  file_prefix = file_name.split('.')[0]

  if generated_type == "model"
    generated_file_path = File.join(@gen_helper.destination_root, "app/models/#{file_prefix}.rb")
    @gen_helper.assert_model_rand_table_name(generated_file_path, fixture_file_path, @table_name)

    require "#{generated_file_path}"
    @model = Object.const_get("#{@model_name}")
  elsif generated_type == "table_config"
    generated_file_path = File.join(@gen_helper.destination_root, "db/table_config/#{file_prefix}.rb")
    @gen_helper.assert_file_fixture(generated_file_path, fixture_file_path)
    
    load generated_file_path
    @table_config = ModelTableConfig.config
  end
end
