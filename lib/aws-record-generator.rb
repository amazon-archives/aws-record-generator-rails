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

    initializer "railtie.configure_rails_initialization" do |app|
      aws_record_is_orm = app.config.generators.rails[:orm] == :aws_record

      args = ARGV.join(' ')
      is_aws_record_cli_orm ||= args.include?('--orm aws_record')
      is_aws_record_cli_orm ||= args.include?('--orm=aws_record')
      is_aws_record_cli_orm ||= args.include?('-o aws_record')
      is_aws_record_cli_orm ||= args.include?('-o=aws_record')

      is_cli_orm_defined ||= args.include?('--orm')
      is_cli_orm_defined ||= args.include?('-o')

      if (is_cli_orm_defined && is_aws_record_cli_orm) || (aws_record_is_orm && (!is_cli_orm_defined || is_aws_record_cli_orm))
        app.config.generators.templates.unshift File::expand_path('../templates', __FILE__)
      end
    end

    rake_tasks do
      load 'tasks/table_config_migrate_task.rake'
    end

  end
end
