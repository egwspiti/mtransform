require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => :spec
RSpec::Core::RakeTask.new('spec') do |t|

end

desc "Start pry console with mtransform required."
task :pry do
  require 'mtransform'
  require 'pry'
  binding.pry
end
