#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2016, <https://github.com/chaos0x8>
#
# \copyright
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# \copyright
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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

multitask(default: Names[main])

task(:clean) {
  sh "rm -rf bin" if File.directory?('bin')
  sh "rm -rf .obj" if File.directory?('.obj')
}
