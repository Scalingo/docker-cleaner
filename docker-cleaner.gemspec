# -*- encoding: utf-8 -*-
require File.expand_path('../lib/docker_cleaner/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "docker-cleaner"
  s.version     = DockerCleaner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Leo Unbekandt"]
  s.email       = ["leo@scalingo.com"]
  s.homepage    = "https://github.com/Scalingo/docker-cleaner"
  s.summary     = "Small utility to clean old containers and images"
  s.description = "Small utility to clean old docker data, containers according to some settings"
  s.license     = "MIT"

  s.add_dependency "docker-api", "~> 2.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = 'lib'
end

