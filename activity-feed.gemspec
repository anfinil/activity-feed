# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activityfeed/version'

Gem::Specification.new do |spec|
  spec.name          = 'activity-feed'
  spec.version       = ActivityFeed::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']

  spec.summary       = %q{This gem implements a Redis-backed time-ordered activity feed for social networks.}
  spec.description   = %q{This gem implements a Redis-backed time-ordered activity feed for social networks.}
  spec.homepage      = 'https://github.com/kigster/ActivityFeed'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'base62-rb'
  spec.add_dependency 'hashie'
  spec.add_dependency 'redis', '~> 3.3'
  spec.add_dependency 'connection_pool', '~> 2.2'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'ventable'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
