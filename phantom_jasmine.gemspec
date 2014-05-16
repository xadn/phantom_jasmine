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

  gem.add_dependency %q{jasmine}, '>= 1.3.1'
  gem.add_dependency %q{facter}, '~> 2.0.1'
  gem.add_dependency %q{phantomjs}, '>= 1.8.1.0'

  gem.add_development_dependency %q{json}
  gem.add_development_dependency %q{rspec}, '>= 2.13.0'
  gem.add_development_dependency %q{fuubar}
  gem.add_development_dependency %q{rake}
end
