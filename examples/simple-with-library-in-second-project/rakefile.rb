gem 'rake-builder'

require 'rake-builder'

external = RakeBuilder::Project.new
external.flags << %w[--std=c++17 -Isrc]

libout = external.library_static 'lib/libout.a' do |t|
  t.sources << %w[src/hello.cpp]
end

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.executable 'bin/out' do |t|
  t.sources << %w[src/main.cpp]
  t.link_static libout
end

desc 'Compile'
multitask compile: project.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project.clean
end
