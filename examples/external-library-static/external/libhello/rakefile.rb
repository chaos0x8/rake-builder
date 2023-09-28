gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.library_static 'lib/libhello.a' do |t|
  t.sources << Dir['src/**/*.cpp']
end

desc 'Compile'
multitask compile: project.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project.clean
end
