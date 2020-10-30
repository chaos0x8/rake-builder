gem 'rake-builder'

require 'rake-builder'

RakeBuilder.verbose = false
RakeBuilder.silent = true

main = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
}

task(default: Names[main])

task(:clean) {
  [RakeBuilder.outDir, 'lib', 'bin'].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
