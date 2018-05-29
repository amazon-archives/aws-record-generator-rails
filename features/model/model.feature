# Copyright 2018-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
  Given an aws-record model definition as:
    """
    id:hkey count:int:rkey
    """
  When we run the ModelGenerator
  Then a "model" should be generated with contents:
    """
    string_attr :id, hash_key: true
    integer_attr :count, range_key: true
    """
  And a "table_config" should be generated with contents:
    """
    t.read_capacity_units 5
    t.write_capacity_units 2
    """
  
  When we migrate the TableConfig
  Then eventually the table should exist in DynamoDB
  And the TableConfig should be compatible with the remote table
  And the TableConfig should be an exact match with the remote table
