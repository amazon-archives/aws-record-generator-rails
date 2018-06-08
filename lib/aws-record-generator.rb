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

require_relative 'generators/generated_attribute'
require_relative 'generators/secondary_index'
require_relative 'generators/test_helper'
require_relative 'generators/aws_record/model/model_generator'

require 'rails/railtie'

module AwsRecord
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/table_config_migrate_task.rake'
    end
  end
end
