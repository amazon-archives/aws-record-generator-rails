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

# language: en
@dynamodb @modelgen
Feature: Aws::Record::Generators::ModelGenerator

Scenario: Create a New Table with ModelGenerator
  Given we will create an aws-record model called: TestModel1, with file prefix: test_model1
  When we run the rails command line with:
    """
    g aws_record:model TestModel1 id:hkey count:int:rkey --table_config read:11 write:4
    """
  Then a "model" should be generated
  And a "table_config" should be generated
  When we run the rails command line with:
    """
    aws_record:migrate
    """

  Then eventually the table should exist in DynamoDB
  And the TableConfig should be compatible with the remote table
  And the TableConfig should be an exact match with the remote table
