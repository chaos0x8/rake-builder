gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.external 'external/libhello' do |t|
  t.command_compile = <<~INLINE
    rake
  INLINE

  t.command_clean = <<~INLINE
    rake clean
  INLINE

  t.provide_include('hello.hpp')
  t.provide_library_static('libhello.a')
end

project.executable 'bin/out' do |t|
  t.sources << Dir['src/**/*.cpp']
end

desc 'Compile'
multitask compile: project.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project.clean
  project.clean_external
end
