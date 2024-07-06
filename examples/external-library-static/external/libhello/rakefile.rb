gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new flags_compile: %w[--std=c++17 -Isrc]
project.library_static path: 'lib/libhello.a',
                       sources: Dir['src/**/*.cpp']
project.define_tasks
