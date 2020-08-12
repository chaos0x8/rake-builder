#!/usr/bin/ruby

gem 'rake-builder', '~> 2.0', '>= 2.0.5'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

main = Executable.new { |t|
    t.name = 'bin/main'
    t.requirements << 'libs:default'
    t.sources << Dir[ 'Source/main.cpp' ]
    t.includes << [ 'Source' ]
    t.flags << [ '--std=c++0x' ]
    t.libs << [ '-lpthread', 'lib/libmain.a' ]
    t.pkgs << ['ruby']
}

desc 'Build testable application'
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
