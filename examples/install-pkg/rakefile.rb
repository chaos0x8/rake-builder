#!/usr/bin/ruby

gem 'rake-builder', '~> 2.0', '>= 2.0.0'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

install = InstallPkg.new(name: :install, pkgs: ['ruby-dev'])

libs = Array.new

libs << Library.new { |t|
    t.name = 'lib/libmain.a'
    t.requirements << install
    t.sources << Dir['Source/*.cpp'] - [ 'Source/main.cpp' ]
    t.includes << [ 'Source' ]
    t.flags << [ '--std=c++0x' ]
    t.pkgs << [ 'ruby' ]
    t.description = 'Build testable library'
}

main = Executable.new { |t|
    t.name = 'bin/main'
    t.requirements << install
    t.sources << Dir[ 'Source/main.cpp' ]
    t.includes << [ 'Source' ]
    t.flags << [ '--std=c++0x' ]
    t.libs << [ '-lpthread', libs ]
    t.pkgs << ['ruby']
    t.description = 'Build testable application'
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
