lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_sns/version'

Gem::Specification.new do |spec|
  spec.name          = 'fake_sns'
  spec.version       = FakeSNS::VERSION
  spec.authors       = ['iain']
  spec.email         = ['iain@iain.nl']
  spec.description   = 'Small Fake version of SNS'
  spec.summary       = 'Small Fake version of SNS'
  spec.homepage      = 'https://github.com/yourkarma/fake_sns'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2.0'
  spec.add_dependency 'faraday', '~> 0.8'
  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'verbose_hash_fetch'
  spec.add_dependency 'virtus', '~> 1.0'
  spec.add_dependency 'hosts', '~> 0.1.1'
  spec.add_dependency 'sudo', '~> 0.2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fake_sqs', '~> 0.2'
  spec.add_development_dependency 'json_expressions'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
