gem 'rake-builder'

require 'rake-builder'

project_a = RakeBuilder::Project.new name: 'a',
                                     flags_compile: %w[--std=c++17 -Isrc
                                                       -DPROJECT_NAME=A]
project_a.executable path: 'bin/project_a',
                     sources: Dir['src/**/*.cpp']

project_b = RakeBuilder::Project.new name: 'b',
                                     flags_compile: %w[--std=c++17 -Isrc
                                                       -DPROJECT_NAME=B]
project_b.executable path: 'bin/project_b',
                     sources: Dir['src/**/*.cpp']

RakeBuilder::Tasks.new default: [project_a, project_b],
                       clean: [project_a, project_b]
