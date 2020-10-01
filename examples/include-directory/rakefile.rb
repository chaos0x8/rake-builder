gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

generated = []
generated << Generate.includeDirectory('Source/Common')

app = Executable.new { |t|
  t.name = 'bin/app'
  t.requirements << generated
  t.sources << 'Source/main.cpp'
}

multitask(default: Names[app, generated])

task(:clean) {
  generated.each { |t|
    FileUtils.rm t.name, verbose: true if File.exist?(t.name)
  }

  [RakeBuilder.outDir, 'bin'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
