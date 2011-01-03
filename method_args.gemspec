# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "method_args/version"

Gem::Specification.new do |s|
  s.name        = "method_args"
  s.version     = MethodArgs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = "https://github.com/joshbuddy/method_args"
  s.summary     = "Get back more detailed information about the arguments for a method"
  s.description = "Get back more detailed information about the arguments for a method"

  s.rubyforge_project = "method_args2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "ruby_parser", "~> 2.0"
  s.add_dependency "ruby2ruby", "~> 1.2.4"
  s.add_dependency "sexp_processor", "~> 3.0.4"
  s.add_development_dependency "callsite", "~> 0.0.4"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "phocus"
  s.add_development_dependency "minitest"
end
