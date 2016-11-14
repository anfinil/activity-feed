require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require 'yard'


YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.md DESIGN.md FEATURES.md SERIALIZATION.md LICENSE.txt)
  t.options.unshift('--title', '"ActivityFeed — Fast and Scalable "write-time" Activity Feed for Social Networks, with a Redis-based default backend implementation."')
  t.after = ->() { exec('open doc/index.html') } if RUBY_PLATFORM =~ /darwin/
end


RSpec::Core::RakeTask.new(:spec)

task :default => :spec
