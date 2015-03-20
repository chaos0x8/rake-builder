#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2015, <https://github.com/chaos0x8>
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

require_relative '../RakeBuilder.rb'

Application.new do |t|
    t.name = "bin/app1"
    t.files = FileList["app1/*.cpp"]
end

task :application => "bin/app1"

Library.new do |t|
    t.name = "lib/libapp2.a"
    t.files = FileList[ "app2/lib.cpp" ]
    t.includes = [ "app2" ]
end

Application.new do |t|
    t.name = "bin/app2"
    t.files = [ "app2/app.cpp" ]
    t.includes = [ "app2" ]
    t.flags = [ "--std=c++11" ]
    t.libs = [ "-Llib", "-lapp2" ]
    t.dependencies = [ "lib/libapp2.a" ]
end

task :library => "bin/app2"

task :default => [ :application, :library ]
