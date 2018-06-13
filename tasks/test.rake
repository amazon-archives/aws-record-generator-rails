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

require 'rspec/core/rake_task'

desc "aws-record-generator unit tests"
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib"
  t.rspec_opts << " -I #{$REPO_ROOT}/spec"
  t.pattern = "#{$REPO_ROOT}/spec"
end

desc 'aws-record integration tests'
task 'test:integration' do |t|
  if ENV['AWS_INTEGRATION']
    exec("bundle exec cucumber -t ~@veryslow")
  else
    puts(<<-MSG)

*** skipping aws-record integration tests ***
  export AWS_INTEGRATION=1 to enable integration tests

    MSG
  end
end
