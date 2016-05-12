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

class TestRakeBuilderNames < Test::Unit::TestCase
    include RakeBuilder

    context('TestRakeBuilderNames') {
        should('return list of strings') {
            assert_equal(['1', 'filename'], Names[1, 'filename'])
        }


        should('extract names from nested arrays') {
            assert_equal(['a', 'b', 'c', 'd'], Names['a', ['b', 'c'], ['d']])
        }

        context('with some target') {
            setup {
                @target = mock()
                @target.expects(:kind_of?).returns(false).at_least(0)
                @target.expects(:kind_of?).with(Target).returns(true).at_least(0)
                @target.expects(:name).returns('target').at_least(0)
            }

            should('extract name from Target') {
                assert_equal(['target'], Names[@target])
            }

            should('extract libs from GitSubmodule') {
                @target.expects(:kind_of?).with(GitSubmodule).returns(true).at_least(0)
                @target.expects(:libs).returns(['lib1', 'lib2']).at_least(0)

                assert_equal(['target/lib1', 'target/lib2'], Names[@target])
            }
        }
    }
end
