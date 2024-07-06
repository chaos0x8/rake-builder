gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new flags_compile: { std: 17 }
project.library_static path: 'bin/libout.a',
                       sources: %w[src/hello.cpp],
                       flags_compile: { I: %w[src] }
project.executable path: 'bin/out',
                   sources: %w[src/main.cpp],
                   flags_link: { link: %w[bin/libout.a] }
project.configure_cmake
project.define_tasks
