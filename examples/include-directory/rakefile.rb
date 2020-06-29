#!/usr/bin/ruby

gem 'rake-builder', '~> 2.0', '>= 2.0.0'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

generated = []
generated << Generate.includeDirectory('Source/Common')

multitask(default: Names[generated])

task(:clean) {
  generated.each { |t|
    FileUtils.rm t.name, verbose: true if File.exist?(t.name)
  }
}
