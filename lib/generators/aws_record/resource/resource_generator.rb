require "rails/generators/rails/resource_route/resource_route_generator"
require "rails/generators/resource_helpers"
require 'generators/aws_record/model/active_model'

module AwsRecord
  module Generators
    class ResourceGenerator < ModelGenerator
      include Rails::Generators::ResourceHelpers

      hook_for :resource_route, in: :rails, required: true

      private
      def orm_class
        @orm_class = AwsRecord::Generators::ActiveModel
      end
    end
  end
end
