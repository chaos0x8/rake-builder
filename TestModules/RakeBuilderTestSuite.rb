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

require 'test/unit'
require 'shoulda'
require 'fileutils'

class RakeBuilderTestSuite < Test::Unit::TestCase
    def teardown
        FileUtils.rm Dir["obj/**/*.o", "obj/**/*.mf"]
        FileUtils.rmdir ["obj/app1", "obj/app2", "obj"]
    end

    context "C++ application" do
        setup do
            FileUtils.touch "app1/app.cpp"
        end

        teardown do
            FileUtils.rm [ "bin/app1" ]
            FileUtils.rmdir [ "bin" ]
        end

        should "compile and run" do
            system "rake application"
            assert_equal(true, File.exist?("bin/app1"))
            assert_equal("Hello World!", `bin/app1`.chomp)
        end
    end

    context "C++ application with library" do
        setup do
            FileUtils.touch "app2/lib.hpp"
        end

        teardown do
            FileUtils.rm [ "bin/app2", "lib/libapp2.a" ]
            FileUtils.rmdir [ "bin", "lib" ]
        end

        should "compile and run" do
            system "rake library"
            assert_equal(true, File.exist?("lib/libapp2.a"))
            assert_equal(true, File.exist?("bin/app2"))
            assert_equal("Library: Hello World!", `bin/app2`.chomp)
        end
    end
end
