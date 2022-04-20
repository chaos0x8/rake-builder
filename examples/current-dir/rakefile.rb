gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'
require 'pathname'

project_name = Pathname.new(__FILE__).dirname.basename.to_s

p = C8.project 'demo' do |_p|
  flags << %w[-std=c++17]

  executable project_name do
    desc 'Builds application'
    sources << Dir['*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh "./#{project_name}"
end

C8.target :clean do
  p.dependencies.each do |path|
    rm path
  end
end
