gem 'rake-builder'

require 'rake-builder'

RakeBuilder.phony :configure do
  IO.write 'src/conf.hpp', <<~INLINE
    #pragma once

    #include <string_view>

    constexpr std::string_view world = "world";
  INLINE
end

project = RakeBuilder::Project.new flags_compile: %w[--std=c++17 -Isrc],
                                   depend: %i[configure]
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp']
project.define_tasks

task :clean do
  FileUtils.rm 'src/conf.hpp', verbose: true if File.exist?('src/conf.hpp')
end
