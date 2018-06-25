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
@dynamodb @modelgen @scaffoldtest
Feature: Aws::Record::Generators::ScaffoldGenerator
Scenario: Create a New Scaffold with ScaffoldGenerator
  When we run the rails command line with:
    """
    g aws_record:scaffold Dog id:hkey name is_good_boy:bool --table_config=primary:11-4
    """
  Then a "model" should be generated matching fixture at: "fixtures/cucumber/model/dog.rb"
  And a "table_config" should be generated matching fixture at: "fixtures/cucumber/table_config/dog_config.rb"

  When we run the rails command line with:
    """
    aws_record:migrate
    """
  Then eventually the table should exist in DynamoDB
  And the TableConfig should be compatible with the remote table
  And the TableConfig should be an exact match with the remote table

  When we navigate to /dogs
  And we click on New Dog
  And we fill the dog_id field with TestDog
  And we fill the dog_name field with Fido
  And we set dog_is_good_boy
  And we click on Create Dog
  Then the current page should be /dogs/TestDog

  When we click on Back
  Then the current page should be /dogs
  And the page should have content:
    """
    Dogs
    Id Name Is good boy
    TestDog Fido true Show Edit Destroy
    
    New Dog
    """

  When we click on Show
  Then the current page should be /dogs/TestDog
  And the page should have content:
    """
    Id: TestDog
    Name: Fido
    Is good boy: true
    Edit | Back
    """

  When we click on Back
  Then the current page should be /dogs
  And the page should have content:
    """
    Dogs
    Id Name Is good boy
    TestDog Fido true Show Edit Destroy
    
    New Dog
    """

  When we click on Edit
  Then the current page should be /dogs/TestDog/edit
  And the page should have content:
    """
    Editing Dog
    Id
    Name
    Is good boy
    Show | Back
    """

  And we fill the dog_name field with Rover
  And we click on Update Dog
  And the current page should be /dogs/TestDog
  
  When we click on Back
  Then the current page should be /dogs
  And the page should have content:
    """
    Dogs
    Id Name Is good boy
    TestDog Rover true Show Edit Destroy
    
    New Dog
    """

  When we click on Destroy
  And we accept the alert
  Then the current page should be /dogs
  And the page should have content:
    """
    Dogs
    Id Name Is good boy
    
    New Dog
    """
  And the page should not have content:
    """
    TestDog Rover true Show Edit Destroy
    """
    