source 'https://rubygems.org'

# We don't require active_record to use minimapper, only to
# use minimapper/mapper. We do require it for the tests though :)
#
# Also locked to below rails 4.0 as our specs use rails 3 features. Need to look into
# if there are any issues with rails 4.
gem "activerecord", "< 4.0"
gem "rspec"

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
