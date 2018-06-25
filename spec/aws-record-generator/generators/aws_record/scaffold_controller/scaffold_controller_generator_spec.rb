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

    describe ScaffoldControllerGenerator do
      before(:all) do
        @gen_helper = GeneratorTestHelper.new(ScaffoldControllerGenerator, "tmp")
      end
      
      after(:all) do
        @gen_helper.cleanup
      end

      it 'generates the controller skeleton properly' do
        @gen_helper.run_generator ["ControllerSkeletonTest", "name", "age:int", "--skip-table-config"]
        
        @gen_helper.assert_file "app/controllers/controller_skeleton_tests_controller.rb" do |content|
          @gen_helper.assert_match(/class ControllerSkeletonTestsController < ApplicationController/, content)
    
          @gen_helper.assert_instance_method :index, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_tests = ControllerSkeletonTest\.scan/, m)
          end
    
          @gen_helper.assert_instance_method :show, content
    
          @gen_helper.assert_instance_method :new, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.new/, m)
          end
    
          @gen_helper.assert_instance_method :edit, content
    
          @gen_helper.assert_instance_method :create, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.new\(controller_skeleton_test_params\)/, m)
            @gen_helper.assert_match(/@controller_skeleton_test\.save/, m)
          end
    
          @gen_helper.assert_instance_method :update, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_test\.update\(controller_skeleton_test_params\)/, m)
          end
    
          @gen_helper.assert_instance_method :destroy, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_test\.delete!/, m)
            @gen_helper.assert_match(/Controller skeleton test was successfully destroyed./, m)
          end
    
          @gen_helper.assert_instance_method :set_controller_skeleton_test, content do |m|
            @gen_helper.assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.find\(uuid: CGI.unescape\(params\[:id\]\)\)/, m)
          end
    
          @gen_helper.assert_instance_method :controller_skeleton_test_params, content do |m|
            @gen_helper.assert_match(/params\.require\(:controller_skeleton_test\)\.permit\(:uuid, :name, :age\)/, m)
          end
        end
      end

      it 'generates the api-controller skeleton properly' do
        @gen_helper.run_generator ["ApiControllerSkeletonTest", "--api","--skip-table-config"]
  
        @gen_helper.assert_file "app/controllers/api_controller_skeleton_tests_controller.rb" do |content|
          @gen_helper.assert_match(/class ApiControllerSkeletonTestsController < ApplicationController/, content)
          @gen_helper.refute_match(/respond_to/, content)
  
          @gen_helper.assert_match(/before_action :set_api_controller_skeleton_test, only: \[:show, :update, :destroy\]/, content)
  
          @gen_helper.assert_instance_method :index, content do |m|
            @gen_helper.assert_match(/@api_controller_skeleton_tests = ApiControllerSkeletonTest\.scan/, m)
            @gen_helper.assert_match(/render json: @api_controller_skeleton_tests/, m)
          end
    
          @gen_helper.assert_instance_method :show, content do |m|
            @gen_helper.assert_match(/render json: @api_controller_skeleton_test/, m)
          end
    
          @gen_helper.assert_instance_method :create, content do |m|
            @gen_helper.assert_match(/@api_controller_skeleton_test = ApiControllerSkeletonTest\.new\(api_controller_skeleton_test_params\)/, m)
            @gen_helper.assert_match(/@api_controller_skeleton_test\.save/, m)
            @gen_helper.assert_match(/@api_controller_skeleton_test\.errors/, m)
          end
    
          @gen_helper.assert_instance_method :update, content do |m|
            @gen_helper.assert_match(/@api_controller_skeleton_test\.update\(api_controller_skeleton_test_params\)/, m)
            @gen_helper.assert_match(/@api_controller_skeleton_test\.errors/, m)
          end
    
          @gen_helper.assert_instance_method :destroy, content do |m|
            @gen_helper.assert_match(/@api_controller_skeleton_test\.delete!/, m)
          end
        end
  
        @gen_helper.assert_no_file "app/views/api_controller_skeleton_tests/index.html.erb"
        @gen_helper.assert_no_file "app/views/api_controller_skeleton_tests/edit.html.erb"
        @gen_helper.assert_no_file "app/views/api_controller_skeleton_tests/show.html.erb"
        @gen_helper.assert_no_file "app/views/api_controller_skeleton_tests/new.html.erb"
        @gen_helper.assert_no_file "app/views/api_controller_skeleton_tests/_form.html.erb"
      end
    end
  end
end
