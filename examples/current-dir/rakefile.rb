gem 'rake-builder'

require 'rake-builder'

demo = project do |p|
  p.flags << %w[-std=c++17]

  p.library 'libhello.a' do |t|
    t.description = 'Builds library'
    t.sources << Dir['*.cpp'] - %w[main.cpp main-ut.cpp]
  end

  p.executable 'demo' do |t|
    t.description = 'Builds application'
    t.sources << %w[main.cpp]
  end

  p.executable 'demo-ut' do |t|
    t.description = 'Builds test application'
    t.sources << %w[main-ut.cpp]
  end
end

desc 'Builds and executes application'
multitask default: [*demo.requirements('demo')] do
  sh File.join('.', 'demo')
end

desc 'Executes test application'
multitask test: [*demo.requirements('demo-ut')] do
  sh File.join('.', 'demo-ut')
end

desc 'Removes build files'
task :clean do
  demo.clean
end
