gem 'rake-builder'

require 'rake-builder'

pkg_config = RakeBuilder::PkgConfig.new %w[ruby]

project = RakeBuilder::Project.new flags_compile: ['--std=c++14', '-Isrc', pkg_config],
                                   flags_link: [pkg_config]
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp']
project.configure_cmake
project.define_tasks
