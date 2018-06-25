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

require "rails/generators/rails/scaffold/scaffold_generator"
require "generators/aws_record/resource/resource_generator"

module AwsRecord
  module Generators
    class ScaffoldGenerator < ResourceGenerator
      source_root File.expand_path('../../model/templates', __FILE__)

      remove_class_option :orm
      remove_class_option :actions

      class_option :api, type: :boolean
      class_option :stylesheets, type: :boolean, desc: "Generate Stylesheets"
      class_option :stylesheet_engine, desc: "Engine for Stylesheets"
      class_option :assets, type: :boolean
      class_option :resource_route, type: :boolean
      class_option :scaffold_stylesheet, type: :boolean

      def handle_skip
        @options = @options.merge(stylesheets: false) unless options[:assets]
        @options = @options.merge(stylesheet_engine: false) unless options[:stylesheets] && options[:scaffold_stylesheet]
      end

      hook_for :scaffold_controller, in: :aws_record, required: true

      hook_for :assets, in: :rails do |assets|
        invoke assets, [controller_name]
      end

      hook_for :stylesheet_engine, in: :rails do |stylesheet_engine|
        if behavior == :invoke
          invoke stylesheet_engine, [controller_name]
        end
      end

      private
      def initialize(args, *options)
        options[0] << "--scaffold"
        super
      end
    end
  end
end
