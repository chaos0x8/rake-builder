gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new flags_compile: { std: 17, I: %w[src] }
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp']
project.configure_cmake
project.define_tasks
