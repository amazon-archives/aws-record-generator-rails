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

require 'capybara/cucumber'
require 'active_model'

Before do
  Capybara.configure do |config|
    config.run_server = false
    config.always_include_port = true
    config.default_driver = :selenium_chrome_headless
    config.app_host = 'http://localhost:8080'
  end
  
  @rails_app = Kernel.spawn("cd tmp/test_app && rails server --port 8080", :out => "tmp/test_server.log")
end

After("@scaffoldtest") do
  Process.kill("TERM", @rails_app)
  Process.wait(@rails_app)
end

When (/^we navigate to (.+)$/) do |url|
  visit url
end

When (/^we fill the (.+) field with (.+)$/) do |field, value|
  fill_in field, with: value, visible: false
end

When (/^we set (.+)$/) do |field|
  check field, visible: false
end

When (/^we click on (.+)$/) do |name|
  click_on name, visible: false
end

When ("we accept the alert") do
  page.driver.browser.switch_to.alert.accept
end

Then (/^the current page should be (.+)$/) do |page_url|
  expect(page).to have_current_path(page_url)
end

Then ("the page should have content:") do |content|
  expect(page).to have_content(content)
end

Then ("the page should not have content:") do |content|
  expect(page).to have_no_content(content)
end
