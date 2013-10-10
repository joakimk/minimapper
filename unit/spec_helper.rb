ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$: << File.join(ROOT, "lib")
$: << File.join(ROOT, "unit")

require "minimapper"

RSpec.configure do |config|
end
