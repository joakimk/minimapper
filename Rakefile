require "bundler/gem_tasks"

namespace :spec do
  task :unit do
    puts "Running unit tests."
    spec_helper_path = File.expand_path("unit/spec_helper.rb")
    system("rspec", "-r#{spec_helper_path}", *Dir["unit/**/*_spec.rb"]) || exit(1)
  end

  task :integrated do
    puts "Running integrated tests."
    integrated_helper_path = File.expand_path("spec/spec_helper.rb")
    system("rspec", "-r#{integrated_helper_path}", *Dir["spec/**/*_spec.rb"]) || exit(1)
  end
end

task :spacer do
  puts
end

task :spec => [ :"spec:unit", :spacer, :"spec:integrated" ]
task :default => :spec
