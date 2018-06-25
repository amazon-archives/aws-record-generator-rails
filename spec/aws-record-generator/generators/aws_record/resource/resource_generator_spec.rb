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

require 'spec_helper'

module AwsRecord
  module Generators

    describe ResourceGenerator do
      before(:all) do
        @gen_helper = GeneratorTestHelper.new(ResourceGenerator, "tmp")
      end
      
      after(:all) do
        @gen_helper.cleanup
      end

      it 'displays the options for inherited options' do
        content = @gen_helper.run_generator ["--help"]
        @gen_helper.assert_match(/--table-config=primary:R-W/, content)
      end

      it 'generates the files of inherited invocations' do
        @gen_helper.run_generator ["InheritedFileGenerationTest", "--table-config=primary:5-3"]
       
        %w(app/models/inherited_file_generation_test.rb db/table_config/inherited_file_generation_test_config.rb).each do |path| 
          @gen_helper.assert_file(path)
        end
      end

      it 'removes a route on revoke' do
        @gen_helper.run_generator ["account", "--table-config=primary:12-4"]
        @gen_helper.run_generator ["account"], behavior: :revoke
    
        @gen_helper.assert_file "config/routes.rb" do |route|
          @gen_helper.refute_match(/resources :accounts$/, route)
        end
      end

    end
  end
end
