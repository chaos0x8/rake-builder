require 'rubygems'

namespace(:gem) {
  gemspec = Gem::Specification.load('rake-builder.gemspec')
  gemFn = "rake-builder-#{gemspec.version}.gem"

  file(gemFn => ['rake-builder.gemspec', 'generated:default']) {
    sh 'gem build rake-builder.gemspec'
    Dir['*.gem'].sort{ |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each { |fn|
      FileUtils.rm(fn, verbose: true)
    }
  }

  task(:default => gemFn)

  task(:install => gemFn) {
    sh 'sudo', 'gem', 'install', '-l', gemFn
  }
}

desc "Builds gem file"
task(:gem => 'gem:default')
