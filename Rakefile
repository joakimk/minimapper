require "bundler/gem_tasks"

namespace :spec do
  task :unit do
    spec_helper_path = File.expand_path("unit/spec_helper.rb")
    system("rspec", "-r#{spec_helper_path}", *Dir["unit/**/*_spec.rb"]) || exit(1)
  end
end

task :default => [ :"spec:unit" ]
