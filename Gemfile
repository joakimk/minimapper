source 'https://rubygems.org'

# ActiveRecord isn't a perfect abstraction so we'll need to test against
# many different databases. To begin with, we're using in-memory sqlite3.
platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "jdbc-sqlite3"
end

# Specify your gem's dependencies in minimapper.gemspec
gemspec
