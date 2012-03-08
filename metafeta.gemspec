# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metafeta"

Gem::Specification.new do |s|
  s.name        = "metafeta"
  s.version     = Metafeta::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mpowered"]
  s.email       = ["mpowered.development@gmail.com"]
  s.summary     = %q{Add metadata to a classes attributes}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
