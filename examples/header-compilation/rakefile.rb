gem 'rake-builder'

require 'rake-builder'

main = Executable.new { |t|
  t.name = 'bin/main'
  t.requirements << :verify
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << ['--std=c++17', '-Wall', '-Werror']
}

headers = FileList['src/**/*.hpp'].collect { |fn|
  HeaderFile.new { |t|
    t.name = fn
    t.flags << main.flags
    t.includes << main.includes
  }
}

C8.task(:verify => Names[headers])

task(default: Names[main])

task(:clean) {
  ['lib', 'bin', '.obj'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
