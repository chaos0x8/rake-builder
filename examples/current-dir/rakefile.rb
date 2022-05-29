gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'
require 'pathname'

project_name = Pathname.new(__FILE__).dirname.basename.to_s

C8.project 'demo' do |_p|
  description 'builds demo project'

  flags << %w[-std=c++17]

  executable project_name do
    description 'Builds application'
    sources << Dir['*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh "./#{project_name}"
end

desc 'Removes build files'
C8.task clean: 'demo:clean'
