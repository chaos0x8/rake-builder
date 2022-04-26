gem 'rake-builder'

require 'rake-builder'

p = C8.project 'demo' do
  flags << %w[--std=c++17 -Wall -Werror]

  executable 'bin/main' do
    sources << Dir['src/**/*.cpp']
  end

  Dir['src/**/*.hpp'].each do |path|
    header path
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
