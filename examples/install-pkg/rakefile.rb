gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

C8.project 'install-pkg' do |p|
  p.build_dir = '.obj'
  p.flags << %w[--std=c++0x -ISource]

  t = p.phony :install_pkgs do
    desc 'Installs preconditions'
    apt_install 'ruby-dev'
  end

  p.executable 'bin/main' do |_t|
    desc 'Build application'
    flags << %w[-lpthread]
    sources << Dir['Source/main.cpp']
  end

  p.library 'lib/libmain.a' do |_t|
    desc 'Build library'
    sources << Dir['Source/*.cpp'] - Dir['Source/main.cpp']
  end
end

C8.target default: 'install-pkg' do
  desc 'Builds and executes binary'
  sh 'bin/main'
end

desc 'Removes build files'
C8.task clean: 'install-pkg:clean'
