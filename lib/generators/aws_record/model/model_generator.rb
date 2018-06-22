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

require 'rails/generators'
require 'aws-record-generator'
require 'generators/aws_record/base'

module AwsRecord
  module Generators
    class ModelGenerator < Base

      def initialize(args, *options)
        self.class.source_root File.expand_path('../templates', __FILE__)
        super
      end

      def create_model
        template "model.rb", File.join("app/models", class_path, "#{file_name}.rb")
      end

      def create_table_config
        template "table_config.rb", File.join("db/table_config", class_path, "#{file_name}_config.rb") unless options.key?(:skip_table_config)
      end

    end
  end
end
