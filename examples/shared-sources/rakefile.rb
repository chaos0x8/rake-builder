#!/usr/bin/ruby

gem 'rake-builder', '~> 1.0', '>= 1.0.0'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

install = InstallPkg.new(name: :install, pkgs: ['ruby-dev'])

sources = mkSources(
  Dir['Source/*.cpp'] - ['Source/main.cpp'],
  flags: ['--std=c++17'],
  pkgs: ['ruby'],
  includes: ['Source'],
  requirements: install)

lib = Library.new { |t|
  t.name = 'lib/libmain.a'
  t.sources << sources
  t.desc = 'Build testable library'
}

main = Executable.new { |t|
  t.name = 'bin/main'
  t.requirements << install
  t.sources << Dir['Source/main.cpp']
  t.includes << ['Source']
  t.flags << ['--std=c++0x']
  t.libs << ['-lpthread', lib]
  t.pkgs << ['ruby']
  t.desc = 'Build testable application'
}

multitask(default: Names[main])

task(:clean) {
  [ 'lib', 'bin', '.obj' ].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
