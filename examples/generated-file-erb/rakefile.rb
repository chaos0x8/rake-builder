gem 'rake-builder'

require 'rake-builder'

p = C8.project 'demo' do
  flags << %w[-Isrc --std=c++17]

  file_generated 'src/enum.hpp' => 'src/enum.hpp.erb' do
    C8.erb(IO.read('src/enum.hpp.erb'), names: %w[a b c])
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
C8.target :clean do
  p.dependencies.each do |path|
    rm path
  end
end
