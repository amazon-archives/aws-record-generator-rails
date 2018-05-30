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

require 'rails/generators/rails/app/app_generator'
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"
require "fileutils"
require "minitest/spec"
require "byebug"

module AwsRecord
  class GeneratorTestHelper
    include Minitest::Assertions
    attr_accessor :assertions

    include Rails::Generators::Testing::Behaviour
    include Rails::Generators::Testing::Assertions
    include FileUtils

    def initialize(klass, dest)
      GeneratorTestHelper.tests klass
      temp_root = File.join(File.expand_path(dest, __dir__), "test_app")
      GeneratorTestHelper.destination temp_root
      
      destination_root_is_set?
      prepare_destination
      setup_test_app
      ensure_current_path

      self.assertions = 0
    end 

    def run_in_test_app(cmd)
      cd destination_root
      a = `rails #{cmd}`

      ensure_current_path
    end

    def cleanup
      rm_rf destination_root
    end

    private

    def setup_test_app
      Rails::Generators::AppGenerator.start [destination_root, '--skip-bundle', '--skip-git', '--skip-spring', '--skip-test', '-d' , '--skip-javascript', '--force', '--quiet']
      `echo 'gem "aws-record-generator", :path => "../../"' >> "#{destination_root}/Gemfile"`
      `bundle install --gemfile "#{destination_root}/Gemfile"`
    end
  end
end
