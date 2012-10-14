source 'https://rubygems.org'

platforms :ruby do
  gem "sqlite3"
  gem "pg"
  gem "mysql2"
  gem "activerecord-mysql2-adapter"
end

platforms :jruby do
  gem "activerecord-jdbcsqlite3-adapter"
  gem "activerecord-jdbcpostgresql-adapter"
  gem "activerecord-jdbcmysql-adapter"
end

# Specify your gem's dependencies in minimapper.gemspec
gemspec
