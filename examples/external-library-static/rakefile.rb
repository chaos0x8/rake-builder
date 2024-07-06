gem 'rake-builder'

require 'rake-builder'

file 'external/libhello/lib/libhello.a' do
  sh 'cd "external/libhello" && rake'
end

project = RakeBuilder::Project.new flags_compile: %w[--std=c++17 -Isrc -Iexternal/libhello/src]
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp'],
                   flags_link: %w[external/libhello/lib/libhello.a]
project.define_tasks

task :clean do
  sh 'cd "external/libhello" && rake clean'
end
