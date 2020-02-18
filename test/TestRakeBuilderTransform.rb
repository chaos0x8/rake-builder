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

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/rake-builder/RakeBuilder'

class TestRakeBuilderTransform < Test::Unit::TestCase
    include RakeBuilder::Transform

    should('change single element to obj') {
        assert_equal('.obj/path/filename.o', to_obj('path/filename.ext'))
    }

    should('change multiple elements to obj') {
        input = ['path1/filename1.ext1', 'path2/filename2.ext2']
        expected = ['.obj/path1/filename1.o', '.obj/path2/filename2.o']

        assert_equal(expected, to_obj(input))
    }

    should('change single element to mf') {
        assert_equal('.obj/path/filename.mf', to_mf('path/filename.ext'))
    }
end
