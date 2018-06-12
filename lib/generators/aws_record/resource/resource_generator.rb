require "rails/generators/rails/resource_route/resource_route_generator"
require "rails/generators/resource_helpers"

module AwsRecord
  module Generators
    class ResourceGenerator < ModelGenerator
      include Rails::Generators::ResourceHelpers

      hook_for :resource_route, in: :rails, required: true
    end
  end
end
