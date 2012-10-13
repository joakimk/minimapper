# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minimapper/version'

Gem::Specification.new do |gem|
  gem.name          = "minimapper"
  gem.version       = Minimapper::VERSION
  gem.authors       = ["Joakim Kolsjö"]
  gem.email         = ["joakim.kolsjo@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "informal"
  gem.add_dependency "rake"

  gem.add_development_dependency "rspec"

  # We don't require active_record to use minimapper, only to
  # use minimapper/ar. We do require it for the tests though :)
  gem.add_development_dependency "activerecord"

  # ActiveRecord isn't a perfect abstraction so we'll need to test against
  # many different databases. To begin with, we're using in-memory sqlite3.
  gem.add_development_dependency "sqlite3"
end
