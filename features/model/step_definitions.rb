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
  @gen_helper = AwsRecord::GeneratorTestHelper.new(AwsRecord::ModelGenerator, "tmp")
end

After("@modelgen") do
  @gen_helper.cleanup
end

Given(/^we will create an aws-record model called: (.+)$/) do |string|
   @table_name = string
end

When("we run the rails command line with:") do |cmd|
  @gen_helper.run_in_test_app cmd
end

Then("a {string} should be generated") do |generated_type|
  if generated_type == "model"
    generated_file_path = File.join(@gen_helper.destination_root, "app/models/#{@table_name}.rb")
    fixture_file_path = File.expand_path("fixtures/model/#{@table_name}.rb")
    @gen_helper.assert_file(generated_file_path, fixture_file_path)

    require "#{file_path}"
    @model = Object.const_get("#{@table_name}")
  elsif generated_type == "table_config"
    generated_file_path = File.join(@gen_helper.destination_root, "db/table_config/#{@table_name}_config.rb")
    fixture_file_path = File.expand_path("fixtures/table_config/#{@table_name}.rb")
    @gen_helper.assert_file(generated_file_path, fixture_file_path)
    
    load file_path
    @table_config = ModelTableConfig.config
  end
end
