gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.generated_file 'src/value0.hpp' do |t|
  t.script do |name|
    IO.write name, <<~INLINE
      #pragma once

      constexpr auto value0 = 32;
    INLINE
  end

  t.dependencies << __FILE__
end

project.generated_file 'src/value1.hpp' do |t|
  val = 70

  t.erb = proc do
    <<~INLINE
      #pragma once

      constexpr auto value1 = <%= val %>;
    INLINE
  end

  t.script do |name, text|
    IO.write(name, text.gsub(/70/, '99'))
  end

  t.dependencies << __FILE__
end

project.generated_file 'src/value2.hpp' do |t|
  t.script do
    IO.write t.path, <<~INLINE
      #pragma once

      constexpr auto value2 = 142;
    INLINE
  end

  t.dependencies << __FILE__
end

project.executable 'bin/out' do |t|
  t.sources << Dir['src/**/*.cpp']
end

desc 'Compile'
multitask compile: project.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project.clean
end
