#!/usr/bin/ruby

desc 'Runs unit tests'
task(:test => 'generated:default') {
  args = Dir['test/Test*.rb'].collect { |fn| ['-e', "require '#{File.expand_path(fn)}'"] }
  sh 'ruby', *args.flatten
}

desc 'Runs all major targets'
task(:all => ['test', 'examples', 'gem'])

desc 'Runs unit tests and creates gem file'
task(:default => ['ut', 'gem'])
