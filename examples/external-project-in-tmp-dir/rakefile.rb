gem 'rake-builder'

require 'rake-builder'
require 'tmpdir'

demo = project do |p|
  p.flags << %w[--std=c++17]

  p.external Pathname.new(Dir.tmpdir).join('.obj/c8-cpp'), :git do |t|
    t.url = 'https://github.com/chaos0x8/c8-cpp'
    t.script = <<~INLINE
      rake c8-common:main
    INLINE

    t.products << %w[libc8-common.a c8-common.hpp]
  end

  p.executable 'bin/main' do |t|
    t.sources << Dir['src/**/*.cpp']
  end
end

desc 'Builds and executes application'
task default: [*demo.requirements] do
  sh 'bin/main'
end

desc 'Removes build files'
task :clean do
  demo.clean
end
