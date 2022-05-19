gem 'rake-builder'

require 'rake-builder'

C8.project 'demo' do
  flags << %w[-Isrc --std=c++17]

  file_generated 'src/enum.hpp' => 'src/enum.hpp.erb' do
    C8.erb names: %w[a b c] do
      IO.read 'src/enum.hpp.erb'
    end
  end

  executable 'bin/main' do
    sources << Dir['src/**/*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh 'bin/main'
end

desc 'Removes build files'
C8.task clean: 'demo:clean'
