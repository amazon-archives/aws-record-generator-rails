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
  if cmd.start_with?('g aws_record:model')
    @table_name = cmd.split(' ')[2]
  end

  @gen_helper.run_in_test_app cmd
end

Then("a {string} should be generated matching fixture at: {string}") do |generated_type, fixture_file_path|
  file_name = fixture_file_path.split('/')[-1]
  file_prefix = file_name.split('.')[0]

  if generated_type == "model"
    generated_file_path = File.join(@gen_helper.destination_root, "app/models/#{file_prefix}.rb")
    @gen_helper.assert_file(generated_file_path, fixture_file_path)

    require "#{generated_file_path}"
    @model = Object.const_get("#{@table_name}")
  elsif generated_type == "table_config"
    generated_file_path = File.join(@gen_helper.destination_root, "db/table_config/#{file_prefix}.rb")
    @gen_helper.assert_file(generated_file_path, fixture_file_path)
    
    load generated_file_path
    @table_config = ModelTableConfig.config
  end
end
