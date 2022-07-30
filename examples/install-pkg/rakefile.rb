gem 'rake-builder'

require 'rake-builder'

demo = project do |p|
  p.flags << %w[--std=c++0x -ISource]

  p.configure :install_ruby do |t|
    t.description = 'Installs preconditions'
    t.apt_install 'ruby-dev'
  end

  p.library 'lib/libmain.a' do |t|
    t.description = 'Build library'
    t.sources << Dir['Source/*.cpp'] - Dir['Source/main.cpp']
  end

  p.executable 'bin/main' do |t|
    t.description = 'Build application'
    t.flags << %w[-lpthread]
    t.sources << Dir['Source/main.cpp']
  end
end

desc 'Builds and executes binary'
multitask default: [*demo.requirements] do
  sh 'bin/main'
end

desc 'Removes build files'
task :clean do
  demo.clean
end
