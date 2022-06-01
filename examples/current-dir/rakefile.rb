gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'
require 'pathname'

project_name = Pathname.new(__FILE__).dirname.basename.to_s

C8.project 'demo' do |_p|
  description 'builds demo project'

  flags << %w[-std=c++17]

  library 'libhello.a' do
    sources << Dir['*.cpp'] - %w[main.cpp main-ut.cpp]
  end

  executable project_name do
    description 'Builds application'
    sources << %w[main.cpp]
  end

  test "#{project_name}-ut", autorun: false do
    description 'Build test application'
    sources << %w[main-ut.cpp]
  end
end

desc 'Builds and executes application'
C8.multitask default: 'demo:all' do
  sh File.join('.', project_name)
end

desc 'Removes build files'
C8.task clean: 'demo:clean'

desc 'Executes test application'
C8.multitask test: 'demo:test' do
  sh File.join('.', "#{project_name}-ut")
end
