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

require_relative 'TestableTarget'

class TestRakeBuilder < Test::Unit::TestCase
    context('TestRakeBuilder') {
        [ Library, SharedLibrary ].each { |clas|
            context("Test#{clas}") {
                should('yield class when creating') {
                    result = nil

                    @sut = clas.new { |t|
                        t.name = clas.to_s

                        result = t
                    }

                    assert_equal(@sut, result)
                }

                should('raise when name not set in yielded block') {
                    assert_raise(RakeBuilder::MissingAttribute) {
                        @sut = clas.new { }
                    }
                }
            }
        }
    }

  context('TestRakeBuilder with nested pkgs') {
    setup {
      @pkgs = Pkg['sfml-all', 'glew']
      @pkgs[0].expects(:flags).returns([]).at_least(0)
      @pkgs[0].expects(:libs).returns(['-lsfml-system']).at_least(0)
      @pkgs[1].expects(:flags).returns(['-I/usr/include/glew']).at_least(0)
      @pkgs[1].expects(:libs).returns(['-lglew']).at_least(0)

      @sut = TestableTarget.new(name: 'dummy') { |t|
        t.flags = [ '--std=c++14' ]
        t.libs = [ '-ldl', @pkgs ]
      }
    }

    should('return flags') {
      assert_equal('--std=c++14 -I/usr/include/glew', @sut.peek(:_flags))
    }

    should('return libs') {
      assert_equal('-ldl -lsfml-system -lglew', @sut.peek(:_libs))
    }
  }
end
