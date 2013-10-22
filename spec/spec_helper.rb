require "active_record"
require "minimapper"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined?(ROOT)

require File.join(ROOT, "spec/support/database_setup")

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE FROM projects; DELETE FROM users;"
  end
end
