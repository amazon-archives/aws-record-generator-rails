version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "aws-record-generator"
  spec.version       = version
  spec.authors       = ["Amazon Web Services"]
  spec.email         = ["yasharm@amazon.com"]

  spec.summary       = "Rails generators for aws-record"
  spec.description   = "Rails generators for aws-record models"
  spec.homepage      = "https://github.com/awslabs/aws-record-generator"
  spec.license       = "Apache 2.0"

  spec.require_paths = ["lib"]
  spec.files = Dir['lib/**/*.rb']

  spec.add_dependency('aws-record', '~> 2')
  spec.add_dependency('rails', '>= 4.2')
end
