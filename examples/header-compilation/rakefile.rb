gem 'rake-builder'

require 'rake-builder'

demo = project do |p|
  p.flags << %w[--std=c++17 -Wall -Werror]

  p.executable 'bin/main' do |t|
    t.sources << Dir['src/**/*.cpp']
  end

  Dir['src/**/*.hpp'].each do |path|
    p.header path
  end
end

desc 'Builds and executes application'
multitask default: [*demo.requirements] do
  sh 'bin/main'
end

desc 'Removes build files'
task :clean do
  demo.clean
end
