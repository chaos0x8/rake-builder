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

class TestRakeBuilderTarget < Test::Unit::TestCase
    context('TestRakeBuilderTarget') {
        setup {
            @sut = Target.new { |t|
                t.name = 'dummy'
            }

            @counter = 0
        }

        should('add unique tasks') {
            @sut.unique('task1') { @counter += 1}
            @sut.unique('task2') { @counter += 1}

            assert_equal(2, @counter)
        }

        should('add skip duplicated tasks') {
            @sut.unique('task3') { @counter += 1}
            @sut.unique('task3') { @counter += 1}

            assert_equal(1, @counter)
        }

        should('yield dirname') {
            dirname = nil

            @sut.unique('dir/file') { |dir|
                dirname = dir
            }

            assert_equal('dir', dirname)
        }
    }

    class TestableTarget < Target
        def initialize &block
            super
        end

        def peek symbol
            send(symbol)
        end
    end

    context('TestRakeBuilderTarget (compatibility with FileList)') {
        setup {
            @sut = TestableTarget.new { |t|
                t.name = 'name'
                t.sources = FileList['*']
                t.includes = FileList['*']
                t.files = FileList['*']
                t.libs = FileList['*']
            }
        }

        should('sources works with Rake::FileList') {
            assert_equal(Array, @sut.peek(:_sources).class)
        }

        should('includes works with Rake::FileList') {
            assert_equal(String, @sut.peek(:_includes).class)
        }

        should('files works with Rake::FileList') {
            assert_equal(Array, @sut.peek(:_files).class)
        }

        should('libs works with Rake::FileList') {
            assert_equal(String, @sut.peek(:_libs).class)
        }
    }
end

