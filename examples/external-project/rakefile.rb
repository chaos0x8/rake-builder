gem 'rake-builder'

require 'rake-builder'

c8 = ExternalProject.new { |t|
  t.name = 'c8'
  t.git = 'https://github.com/chaos0x8/c8-cpp'
  t.libs << 'libc8-common.a'
  t.includes << 'c8-common.hpp'
  t.rake_tasks << 'lib/libc8-common.a'
}

main = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
  t << c8
}

task(default: Names[main])

task(:clean) {
  ['lib', 'bin', '.obj'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
