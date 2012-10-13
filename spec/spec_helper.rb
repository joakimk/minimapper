require "active_record"
require "minimapper"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined?(ROOT)
Dir[File.join(ROOT, "spec/support/shared_examples/*.rb")].each { |f| require f }

if RUBY_PLATFORM == "java"
  ActiveRecord::Base.establish_connection :adapter => "jdbcsqlite3", :database => ":memory:"
else
  ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE FROM projects;"
  end
end

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :projects, :force => true do |t|
      t.string :name
    end
  end
end
