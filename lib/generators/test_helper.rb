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
