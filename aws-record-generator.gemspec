version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "aws-record-generator"
  spec.version       = version
  spec.authors       = ["Amazon Web Services"]
  spec.email         = ["yasharm@amazon.com"]

  spec.summary       = "Rails generators for aws-record"
  spec.description   = "Provides generators that integrate aws-record models with Rails scaffolding"
  spec.homepage      = "https://github.com/awslabs"
  spec.license       = "Apache 2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.require_paths = ["lib"]
  spec.files = Dir['lib/**/*.rb']

  spec.add_dependency('aws-record', '~> 1.0')
  spec.add_dependency('rails', '~> 5.2.0')
end
