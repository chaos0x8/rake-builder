gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

p = C8.project 'demo' do
  flags << %w[--std=c++17 -ISource]

  phony 'install_pkgs' do
    apt_install 'ruby-dev'
  end

  executable 'bin/main' do
    sources << Dir['Source/*.cpp']
  end

  executable 'bin/main2' do
    sources << Dir['Source/*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh 'bin/main'
  sh 'bin/main2'
end

desc 'Removes build files'
C8.target :clean do
  p.dependencies.each do |path|
    rm path
  end
end
