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

require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"
require "fileutils"
require "minitest/spec"

module AwsRecord
  class GeneratorTestHelper
    include Minitest::Assertions
    attr_accessor :assertions

    include Rails::Generators::Testing::Behaviour
    include Rails::Generators::Testing::Assertions
    include FileUtils

    def initialize(klass, dest)
      GeneratorTestHelper.tests klass
      GeneratorTestHelper.destination File.expand_path(dest, __dir__)
      
      destination_root_is_set?
      prepare_destination
      ensure_current_path

      self.assertions = 0
    end 

    def cleanup
      rm_rf destination_root
    end
  end
end
