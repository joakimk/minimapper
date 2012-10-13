ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$: << File.join(ROOT, "lib")
$: << File.join(ROOT, "unit")

require 'minimapper'

Dir[File.join(ROOT, "spec/support/shared_examples/*.rb")].each { |f| require f }

RSpec.configure do |config|
end
