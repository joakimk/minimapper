require "active_record"
require "minimapper"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined?(ROOT)

require File.join(ROOT, "spec/support/database_setup")

RSpec.configure do |config|
  config.before(:each) do
    # Note: Must be separate statements to work in MySQL...
    ActiveRecord::Base.connection.execute "DELETE FROM users;"
    ActiveRecord::Base.connection.execute "DELETE FROM projects;"
  end
end
