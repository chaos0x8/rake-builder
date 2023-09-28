gem 'rake-builder'

require 'rake-builder'

C8.phony :configure do
  IO.write 'src/conf.hpp', <<~INLINE
    #pragma once

    #include <string_view>

    constexpr std::string_view world = "world";
  INLINE
end

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.executable 'bin/out' do |t|
  t.dependencies << %i[configure]
  t.sources << Dir['src/**/*.cpp']
end

desc 'Compile'
multitask compile: project.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project.clean
  FileUtils.rm 'src/conf.hpp', verbose: true if File.exist?('src/conf.hpp')
end
