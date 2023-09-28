gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new
project.flags << %w[--std=c++17 -Isrc]

project.generated_file 'src/value0.hpp' do |t|
  t.erb = <<~INLINE
    #pragma once

    constexpr auto value0 = 42;
  INLINE

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
