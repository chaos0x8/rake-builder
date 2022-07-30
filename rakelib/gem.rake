require 'rubygems'

namespace(:gem) do
  gemspec = Gem::Specification.load('rake-builder.gemspec')
  gemFn = "rake-builder-#{gemspec.version}.gem"

  file(gemFn => %w[rake-builder.gemspec] + Dir['lib/**/*.rb']) do
    sh 'gem build rake-builder.gemspec'
    Dir['*.gem'].sort { |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each do |fn|
      FileUtils.rm(fn, verbose: true)
    end
  end

  task(default: gemFn)

  task(install: gemFn) do
    sh 'sudo', 'gem', 'install', '-l', gemFn
  end
end

desc 'Builds gem file'
task(gem: 'gem:default')
