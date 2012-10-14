require "active_record"
require "minimapper"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined?(ROOT)
Dir[File.join(ROOT, "spec/support/shared_examples/*.rb")].each { |f| require f }

require File.join(ROOT, "spec/support/database_setup")

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE FROM projects;"
  end
end
