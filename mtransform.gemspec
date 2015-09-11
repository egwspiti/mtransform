# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtransform/version'

Gem::Specification.new do |spec|
  spec.name          = "mtransform"
  spec.version       = Mtransform::VERSION
  spec.authors       = ["egwspiti"]
  spec.email         = ["egwspiti@users.noreply.github.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['Rakefile', 'README.md', 'LICENSE.txt', 'lib/**/*']
  spec.executables   = []
  spec.test_files    = Dir['spec/**/*']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
