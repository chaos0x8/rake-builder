gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

C8.project 'demo' do
  templates.cpp_include_directory 'Source/Common.hpp' => Dir['Source/Common/*.hpp']

  executable 'bin/main' do
    sources << %w[Source/main.cpp]
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh 'bin/main'
end

desc 'Removes build files'
C8.task clean: 'demo:clean'
