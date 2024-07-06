gem 'rake-builder'

require 'rake-builder'

file 'src/value0.hpp' do |t|
  IO.write t.name, <<~INLINE
    #pragma once

    constexpr auto value0 = 32;
  INLINE
end

file 'src/value1.hpp' do |t|
  IO.write t.name, <<~INLINE
    #pragma once

    constexpr auto value1 = 142;
  INLINE
end

project = RakeBuilder::Project.new flags_compile: %w[--std=c++17 -Isrc],
                                   depend: %w[src/value0.hpp src/value1.hpp]
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp']
project.define_tasks

task :clean do
  %w[src/value0.hpp src/value1.hpp].each do |path|
    path = Pathname.new(path)
    FileUtils.rm path, verbose: true if path.exist?
  end
end
