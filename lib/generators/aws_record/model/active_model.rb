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

module AwsRecord
    module Generators
      class ActiveModel
        attr_reader :name
  
        def initialize(name)
          @name = name
        end
  
        # GET index
        def self.all(klass)
          "#{klass}.scan" # TODO No God no plz no.
        end
  
        # GET show
        # GET edit
        # PATCH/PUT update
        # DELETE destroy
        def self.find(klass, attrs)
          hkey = attrs.select{|attr| attr.options[:hash_key]}[0]
          rkey = attrs.select{|attr| attr.options[:range_key]}
          rkey = !rkey.empty? ? rkey[0] : nil

          if rkey
            """lambda {
              id = params[:id].split('&').map{ |param| CGI.unescape(param) }
              #{klass}.find(#{hkey.name}: id[0], #{rkey.name}: id[1])
            }.call()"""
          else
            "#{klass}.find(#{hkey.name}: CGI.unescape(params[:id]))"
          end
        end
  
        # GET new
        # POST create
        def self.build(klass, params = nil)
          if params
            "#{klass}.new(#{params})"
          else
            "#{klass}.new"
          end
        end
  
        # POST create
        def save
          "#{name}.save"
        end
  
        # PATCH/PUT update
        def update(params = nil)
          "#{name}.update(#{params})"
        end
  
        # POST create
        # PATCH/PUT update
        def errors
          "#{name}.errors"
        end
  
        # DELETE destroy
        def destroy
          "#{name}.delete!"
        end
      end
    end
  end
  