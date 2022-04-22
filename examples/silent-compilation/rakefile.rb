gem 'rake-builder'

require 'rake-builder'

p = C8.project 'demo' do |p|
  p.verbose = false
  p.silent = true

  flags << %w[--std=c++17 -Isrc]

  executable 'bin/main' do
    sources << Dir['src/**/*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh 'bin/main'
end

desc 'Removes build files'
C8.target :clean do
  p.dependencies.each do |path|
    rm path
  end
end
