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

require 'aws-sdk-core'
require 'aws-record'

def cleanup_table
  begin
    puts "Cleaning Up Table: #{@table_name}"
    @client.delete_table(table_name: @table_name)
    puts "Cleaned up table: #{@table_name}"
    @table_name = nil
  rescue Aws::DynamoDB::Errors::ResourceNotFoundException
    puts "Cleanup: Table #{@table_name} doesn't exist, continuing."
    @table_name = nil
  rescue Aws::DynamoDB::Errors::ResourceInUseException => e
    puts "Failed to delete table, waiting to retry."
    @client.wait_until(:table_exists, table_name: @table_name)
    sleep(10)
    retry
  end
end
  
Before do
  if !ENV.key? "AWS_REGION"
    raise NameError.new("Please set your AWS_REGION")
  end

  @client = Aws::DynamoDB::Client.new(region: ENV["AWS_REGION"])
end
  
After("@dynamodb") do
  cleanup_table
end  

Then(/^eventually the table should exist in DynamoDB$/) do
  @client.wait_until(:table_exists, table_name: @table_name) do |w|
    w.delay = 5
    w.max_attempts = 25
  end
  true
end

Then(/^the TableConfig should be compatible with the remote table$/) do
  expect(@table_config.compatible?).to be_truthy
end
  
Then(/^the TableConfig should be an exact match with the remote table$/) do
  expect(@table_config.exact_match?).to be_truthy
end
