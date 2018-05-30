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

require 'generators/test_helper'
require 'generators/aws_record/model/model_generator'

Before do
  @gen_helper = AwsRecord::GeneratorTestHelper.new(AwsRecord::ModelGenerator, File.expand_path("tmp"))
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

Then("a {string} should be generated with contents:") do |generated_type, body|
  if generated_type == "model"
    full_contents = 
    """
    ^class #{@table_name}
      #{body}
    end
    """
    
    file_path = File.join(@gen_helper.destination_root, "app/models/#{@table_name}.rb")
    @gen_helper.assert_file(file_path, /#{Regexp.quote(full_contents)}/)


    require "#{file_path}"
    @model = Object.const_get("#{@table_name}")
  elsif generated_type == "table_config"
    full_contents = 
    """
    ^module ModelTableConfig
      def self.config
        Aws::Record::TableConfig.define do |t|
          t.model_class #{@table_name}
          #{body}
        end
      end
    end
    """

    file_path = File.join(@gen_helper.destination_root, "db/table_config/#{@table_name}_config.rb")
    @gen_helper.assert_file(file_path, /#{Regexp.quote(full_contents)}/)
    
    load file_path
    @table_config = ModelTableConfig.config
  end
end
