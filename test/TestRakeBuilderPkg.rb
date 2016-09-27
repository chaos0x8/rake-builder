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

require_relative '../lib/RakeBuilder'

class TestRakeBuilderPkg < Test::Unit::TestCase
  context('TestRakeBuilderPkg') {
    setup {
      @pakage = 'sfml-all'
      @sut = Pkg.new(@pakage)
      @sut.expects(:`).with('pkg-config --cflags sfml-all').returns('--std=c++11 -I/usr/lib/sfml').at_least(0)
      @sut.expects(:`).with('pkg-config --libs sfml-all').returns('-lsfml-system -lsfml-window').at_least(0)
    }

    should('return flags') {
      assert_equal(['--std=c++11', '-I/usr/lib/sfml'], @sut.flags)
    }

    should('return libs') {
      assert_equal(['-lsfml-system', '-lsfml-window'], @sut.libs)
    }

    context('with pkg array') {
      setup {
        @object1 = Object.new
        @object2 = Object.new

        Pkg.expects(:new).with('sfml-all').returns(@object1).at_least(0)
        Pkg.expects(:new).with('glew').returns(@object2).at_least(0)
      }

      should('return Pkg array') {
        assert_equal([@object1, @object2], Pkg['sfml-all', 'glew'])
      }
    }
  }
end

