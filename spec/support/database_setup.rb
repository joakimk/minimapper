class DB
  POSTGRES_USERNAME = ENV['CI'] ? 'postgres' : ENV['USER']

  def use_sqlite3
    if RUBY_PLATFORM == "java"
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

  private

  def connect(opts)
    ActiveRecord::Base.establish_connection(opts)
  end
end

if !ENV['DB']
  DB.new.use_sqlite3
elsif ENV['DB'] == 'postgres'
  DB.new.use_postgres
end

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :projects, :force => true do |t|
      t.string :name
    end
  end
end
