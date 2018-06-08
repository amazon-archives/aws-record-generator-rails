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
    describe SecondaryIndex do

      context 'when given correct params' do
        it 'sets its properties correctly' do
          params = "Model:hkey{uuid},rkey{title}"
        
          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq("Model")
          expect(idx.hash_key).to eq("uuid")
          expect(idx.range_key).to eq("title")
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'sets its properties correctly independent of input order' do
          params = "Model:proj_type{ALL},hkey{uuid}"

          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq("Model")
          expect(idx.hash_key).to eq("uuid")
          expect(idx.range_key).to eq(nil)
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'correctly handles underscores in field names' do 
          params = "Model:hkey{long_uuid}"

          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq("Model")
          expect(idx.hash_key).to eq("long_uuid")
        end
      end

      context 'when given incorrect params' do

        it 'handles not being given a hash_key' do
          params = "Model:rkey{title}"

          expect {
            idx = SecondaryIndex.parse(params)
          }.to raise_error(ArgumentError)
        end

        it 'handles not being given any keys' do
          params = "Model"

          expect {
            idx = SecondaryIndex.parse(params)
          }.to raise_error(ArgumentError)
        end
      end

      context 'when using a projection' do
        it 'correctly handles an ALL projection type' do
          params = "Model:hkey{uuid},proj_type{ALL}"
        
          idx = SecondaryIndex.parse(params)
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'correctly handles an KEYS_ONLY projection type' do
          params = "Model:hkey{uuid},proj_type{KEYS_ONLY}"

          expect {
            idx = SecondaryIndex.parse(params)
        }.to raise_error(NotImplementedError)
        end

        it 'correctly handles an INCLUDE projection type' do
          params = "Model:hkey{uuid},proj_type{INCLUDE}"
        
          expect {
            idx = SecondaryIndex.parse(params)
          }.to raise_error(NotImplementedError)
        end

        it 'handles invalid projection type types' do
          params = "Model:hkey{uuid},proj_type{INCLUDES}"
        
          expect {
            idx = SecondaryIndex.parse(params)
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
