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

desc "Run all table configs in table_config folder"

namespace :aws_record do
  task migrate: :environment do
    Dir[File.join('db', 'table_config', '**/*.rb')].each do |filename|
      puts "running #{filename}"
      require (File.expand_path(filename))

      table_config = ModelTableConfig.config
      table_config.migrate! unless table_config.compatible?
    end
  end
end
