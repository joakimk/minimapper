source 'https://rubygems.org'

# We don't require active_record to use minimapper, only to
# use minimapper/ar. We do require it for the tests though :)
gem "activerecord"
gem "rspec"

# For generating API documentation
gem "tomdoc"
gem "redcarpet"

platforms :ruby do
  gem "sqlite3"
  gem "pg"
  gem "mysql2"
end

platforms :jruby do
  gem "activerecord-jdbcsqlite3-adapter"
  gem "activerecord-jdbcpostgresql-adapter"
  gem "activerecord-jdbcmysql-adapter"
end

# Specify your gem's dependencies in minimapper.gemspec
gemspec
