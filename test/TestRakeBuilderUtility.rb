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

class TestRakeBuilderUtility < Test::Unit::TestCase
    include RakeBuilder::Utility

    context('TestRakeBuilderUtility::readDependencies') {
        setup {
            @filename = 'filename'

            @content = 'UnitTestSuite.o: Test/Source/UnitTestSuite.cpp \\' + "\n" +
                       ' Source/Game/Source/Unit.hpp Source/Interfaces/Source/IObject.hpp'

            @file = Object.new
            @file.expects(:read).returns(@content).at_least(0)

            File.expects(:exists?).returns(false).at_least(0)
            File.expects(:exists?).with(@filename).returns(true).at_least(0)
            File.expects(:open).with(@filename, 'r').yields(@file).at_least(0)
        }

        should('return list of dependent files') {
            expected = [ 'Test/Source/UnitTestSuite.cpp',
                         'Source/Game/Source/Unit.hpp',
                         'Source/Interfaces/Source/IObject.hpp' ]

            assert_equal(expected, readDependencies(@filename))
        }

        should('return empty array when file doesn\'t exists') {
            File.expects(:exists?).with(@filename).returns(false).at_least(0)

            assert_equal([], readDependencies(@filename))
        }
    }

    context('TestRakeBuilderUtility::onlyBasename') {
        [ 'path/filename.extension', 'filename', 'path/filename', 'filename.extension' ].each_with_index { |v, i|
            should("return basename without extension/#{i}") {
                assert_equal('filename', onlyBasename(v))
            }
        }
    }
end

