gem 'rake-builder'

require 'rake-builder'

enum = GeneratedFile.new(format: true) { |t|
  t.name = 'src/enum.hpp'
  t.requirements << 'src/enum.hpp.erb'
  t.code = proc {
    C8.erb(IO.read('src/enum.hpp.erb'), names: ['a', 'b', 'c'])
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
  [RakeBuilder.outDir, 'lib', 'bin', *Names[enum]].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
