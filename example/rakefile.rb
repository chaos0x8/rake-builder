#!/usr/bin/ruby

require_relative '../lib/RakeBuilder'

libs = Array.new

libs << Library.new { |t|
    t.name = 'bin/libmain.a'
    t.sources << Dir['Source/*.cpp'] - [ 'Source/main.cpp' ]
    t.includes << [ 'Source' ]
    t.flags << [ '--std=c++0x' ]
    t.pkgs << [ 'ruby' ]
    t.description = 'Build testable library'
}

main = Executable.new { |t|
    t.name = 'bin/main'
    t.sources << Dir[ 'Source/main.cpp' ]
    t.includes << [ 'Source' ]
    t.flags << [ '--std=c++0x' ]
    t.libs << [ '-lpthread', libs ]
    t.pkgs << ['ruby']
    t.description = 'Build testable application'
}

multitask(default: RakeBuilder::Names[main])

task(:clean) {
  sh "rm -rf bin" if File.directory?('bin')
  sh "rm -rf .obj" if File.directory?('.obj')
}
