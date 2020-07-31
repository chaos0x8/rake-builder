#!/usr/bin/ruby

require_relative 'lib/rake-builder'

require 'rubygems'

gemspec = Gem::Specification.load('rake-builder.gemspec')
gemFn = "rake-builder-#{gemspec.version}.gem"

desc 'Runs unit tests'
task(:ut) {
  args = Dir['test/Test*.rb'].collect { |fn| ['-e', "require '#{File.expand_path(fn)}'"] }
  sh 'ruby', *args.flatten
}

desc 'Runs compilation tests'
task(:test => [gemFn, :ut]) {
  sh 'sudo', 'gem', 'install', '-l', gemFn

  Dir['examples/*'].each { |dir|
    Dir.chdir(dir) {
      sh 'rake', 'clean'
      sh 'rake'
    }
  }
}

desc 'Builds gem file'
file(gemFn => ['rake-builder.gemspec', 'generated:all']) {
  sh 'gem build rake-builder.gemspec'
  Dir['*.gem'].sort{ |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each { |fn|
    FileUtils.rm(fn, verbose: true)
  }
}

desc "Builds gem file"
task(:gem => gemFn)

