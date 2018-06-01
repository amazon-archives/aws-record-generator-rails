desc "Run all table configs in table_config folder"

namespace :aws_record do
  task migrate: :environment do
    Dir[File.join('db', 'table_config', '*.rb')].each do |filename|
      puts "running #{filename}"
      load(filename)
    end
  end
end
