#!/usr/bin/ruby

gem 'rake-builder', '~> 2.0', '>= 2.0.1'

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

  ['.obj', 'bin'].each { |fn|
    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)
  }
}
