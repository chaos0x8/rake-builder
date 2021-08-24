gem 'rake-builder'

require 'rake-builder'

require 'tmpdir'

c8 = ExternalProject.new { |t|
  t.name = 'c8'
  t.git = 'https://github.com/chaos0x8/c8-cpp'
  t.libs << 'libc8-common.a'
  t.includes << 'c8-common.hpp'
  t.rakeTasks << 'lib/libc8-common.a'
  t.outDir = File.join(Dir.tmpdir, '.obj')
  t.noRebuild = true
}

main = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
  t << c8
}

task(default: Names[main]) {
  modulePath = File.join(Dir.tmpdir, '.obj/c8-cpp')
  raise "Missing external module '#{modulePath}'" unless File.directory?(modulePath)
}

task(:clean) {
  ['lib', 'bin', RakeBuilder.outDir].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
