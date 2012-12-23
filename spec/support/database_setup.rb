class DB
  POSTGRES_USERNAME = ENV['CI'] ? 'postgres' : ENV['USER']

  def use_sqlite3
    if jruby?
      connect :adapter => "jdbcsqlite3", :database => ":memory:"
    else
      connect :adapter => "sqlite3", :database => ":memory:"
    end
  end

  def use_postgres
    system "psql -c 'create database minimapper_test;' -d postgres -U #{POSTGRES_USERNAME} 2> /dev/null"
    connect :adapter => "postgresql", :database => "minimapper_test",
            :username => POSTGRES_USERNAME
  end

  def use_mysql
    system "mysql -e 'create database minimapper_test;' 2> /dev/null"
    adapter = jruby? ? "jdbcmysql" : "mysql2"
    connect :adapter => adapter, :database => "minimapper_test",
            :username => "root"
  end

  private

  def jruby?
    RUBY_PLATFORM == "java"
  end

  def connect(opts)
    ActiveRecord::Base.establish_connection(opts)
  end
end

case ENV['DB']
when 'postgres'
  DB.new.use_postgres
when 'mysql'
  DB.new.use_mysql
else
  DB.new.use_sqlite3
end

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :projects, :force => true do |t|
      t.string :name
      t.boolean :visible
    end
  end
end
