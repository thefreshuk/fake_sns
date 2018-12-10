require 'bundler/gem_tasks'

require 'tempfile'
require 'rspec/core/rake_task'

namespace :spec do
  desc 'Run specs with in-memory database'
  RSpec::Core::RakeTask.new(:memory) do |_t|
    ENV['SNS_DATABASE'] = ':memory:'
  end

  desc 'Run specs with file database'
  RSpec::Core::RakeTask.new(:file) do |_t|
    file = Tempfile.new(['rspec-sns', '.yml'], encoding: 'utf-8')
    ENV['SNS_DATABASE'] = file.path
  end
end

desc 'Run spec suite with both in-memory and file'
task spec: ['spec:memory', 'spec:file']

task default: :spec
