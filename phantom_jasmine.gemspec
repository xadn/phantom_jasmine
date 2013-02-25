# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phantom_jasmine/version'

Gem::Specification.new do |gem|
  gem.name          = "phantom_jasmine"
  gem.version       = PhantomJasmine::VERSION
  gem.authors       = ["Ryan Dy"]
  gem.email         = ["ryan.dy@gmail.com"]
  gem.description   = %q{Adds a new rake task jasmine:phantom that runs specs in parallel using phantoms js.}
  gem.summary       = %q{an extension for running jasmine with phantom js in parallel}
  gem.homepage      = "https://github.com/rdy/phantom_jasmine"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.extensions = ['ext/mkrf_conf.rb']

  gem.add_dependency %q{jasmine}, '>= 1.2'
  gem.add_dependency %q{phantomjs-mac}, '>= 0.0.3'
end
