#!/usr/bin/ruby

require_relative '../lib/RakeBuilder'

libs = Array.new

libs << Library.new { |t|
    t.name = 'bin/libmain.a'
    t.sources = Dir['Source/*.cpp'] - [ 'main.cpp' ]
    t.includes = [ 'Source' ]
    t.flags = [ '--std=c++0x' ]
    t.description = 'Build testable library'
}

Executable.new { |t|
    t.name = 'bin/main'
    t.sources = [ 'Source/main.cpp' ]
    t.includes = [ 'Source' ]
    t.flags = [ '--std=c++0x' ]
    t.libs = [ '-lpthread', Pkg['ruby-1.9'], libs ]
    t.description = 'Build testable application'
}

task(:default => 'bin/main')

