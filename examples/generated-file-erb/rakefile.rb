gem 'rake-builder'

require 'rake-builder'

enum = GeneratedFile.new(format: true) { |t|
  t.name = 'src/enum.hpp'
  t.requirements << 'src/enum.hpp.erb'
  t.code = proc {
    C8.erb('src/enum.hpp.erb', names: ['a', 'b', 'c'])
  }
}

main = Executable.new { |t|
  t.name = 'bin/main'
  t.requirements << enum
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
}

task(default: Names[main])

task(:clean) {
  [RakeBuilder.outDir, 'lib', 'bin'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
