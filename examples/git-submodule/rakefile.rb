gem 'rake-builder'

require 'rake-builder'

c8 = ExternalProject.new { |t|
  t.name = 'c8'
  t.submodule = 'c8-cpp'
  t.libs << 'lib/libc8-common.a'
  t.includes << 'c8-common.hpp'
  t.rakeTasks << 'lib/libc8-common.a'
}

main = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << FileList['src/*.cpp']
  t.includes << ['c8-cpp/src']
  t << c8
}

task(default: Names[main])

task(:clean) {
  [RakeBuilder.outDir, 'bin'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
