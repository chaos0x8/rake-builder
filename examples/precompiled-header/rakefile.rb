gem 'rake-builder'

require 'rake-builder'

main = Executable.new { |t|
  t.name = 'bin/main'
  t.requirements << :precompiled
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
}

ph = PrecompiledHeaderFile.new { |t|
  t.name = 'src/header.hpp'
  t.flags << main.flags
  t.includes << main.includes
}

C8.task(precompiled: Names[ph])

task(default: Names[main])

task(:clean) {
  ['lib', 'bin', RakeBuilder.outDir].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }

  Dir['src/**/*.hpp.gch'].each { |fn|
    FileUtils.rm fn, verbose: true
  }
}
