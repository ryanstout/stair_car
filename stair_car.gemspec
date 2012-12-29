# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "stair_car"
  gem.version       = "0.1.0"
  gem.authors       = ["Ryan Stout"]
  gem.email         = ["ryanstout@gmail.com"]
  gem.description   = "StairCar is a fully featured matrix library for jruby (think matlab or numpy)"
  gem.summary       = "StairCar makes it easy to do large scale matrix operations in jruby"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "rspec"
  gem.add_development_dependency 'rdoc', '~> 3.12'
end
