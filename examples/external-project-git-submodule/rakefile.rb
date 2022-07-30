gem 'rake-builder'

require 'rake-builder'

demo = project do |p|
  p.external 'c8-cpp', :submodule do |t|
    t.script = <<~INLINE
      rake c8-common:main
    INLINE

    t.products << %w[libc8-common.a c8-common.hpp]
  end

  p.executable 'bin/main' do |t|
    t.sources << Dir['src/*.cpp']
  end
end

desc 'Builds and executes application'
C8.task default: [*demo.requirements] do
  sh 'bin/main'
end

desc 'Removes build files'
C8.task :clean do
  demo.clean
end
