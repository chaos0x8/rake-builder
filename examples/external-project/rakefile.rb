gem 'rake-builder'

require 'rake-builder'

p = C8.project 'demo' do
  flags << %w[--std=c++17]

  external build_dir.join('c8-cpp'), :git do
    url 'https://github.com/chaos0x8/c8-cpp'

    products << %w[libc8-common.a c8-common.hpp]

    script <<~INLINE
      rake lib/libc8-common.a
    INLINE
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
