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

      @sut.expects(:directory).at_most(0)

      @counter = 0
    }

    should('add unique tasks') {
      @sut.unique('task1') { @counter += 1}
      @sut.unique('task2') { @counter += 1}

      assert_equal(2, @counter)
    }

    should('skip duplicated tasks') {
      @sut.unique('task3') { @counter += 1}
      @sut.unique('task3') { @counter += 1}

      assert_equal(1, @counter)
    }

    should('skip duplicated tasks when added without block') {
      @sut.unique('task4')
      @sut.unique('task4') { @counter += 1}

      assert_equal(0, @counter)
    }

    should('yield dirname') {
      dirname = nil

      @sut.expects(:directory).with('dir')
      @sut.unique('dir/file') { |dir|
        dirname = dir
      }

      assert_equal('dir', dirname)
    }

    should('add only unique directory tasks') {
      @sut.expects(:directory).with('dir1')
      @sut.expects(:directory).with('dir2')

      @sut.unique('dir1/file1') { |dir| }
      @sut.unique('dir1/file2') { |dir| }
      @sut.unique('dir2/file1') { |dir| }
    }

    should('raise when unknown arity detected') {
      assert_raise(RuntimeError) {
        @sut.unique('') { |a, b| }
      }
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

  context('TestRakeBuilderTarget (dispatch process)') {
    setup {
      @generated = Generated.new { |t|
        t.name = '|gen|'
        t.code = Proc.new { }
      }

      @tar = Target.new { |t|
        t.name = '|tar|'
      }

      @pkg = mock()
      @pkg.expects(:kind_of?).returns(false).at_least(0)
      @pkg.expects(:kind_of?).with(Pkg).returns(true).at_least(0)
      @pkg.expects(:flags).returns(['f1', 'f2']).at_least(0)
      @pkg.expects(:libs).returns(['l1', 'l2']).at_least(0)
    }

    should('dispatch files') {
      @sut = TestableTarget.new { |t|
        t.name = 'sut'
        t.files = [ 'a', @generated, FileList['x'], [ 'b', 'c' ]]
      }

      assert_equal(['a', '|gen|', 'x', 'b', 'c'], @sut.peek(:_files))
    }

    should('dispatch sources') {
      @sut = TestableTarget.new { |t|
        t.name = 'sut'
        t.sources = [ 'a', FileList['x'], [ 'b', 'c' ]]
      }

      assert_equal(['a', 'x', 'b', 'c'], @sut.peek(:_sources))
    }

    should('dispatch includes') {
      @sut = TestableTarget.new { |t|
        t.name = 'sut'
        t.includes = [ 'a', FileList['x'], [ 'b', 'c' ]]
      }

      assert_equal('-Ia -Ix -Ib -Ic', @sut.peek(:_includes))
    }

    should('dispatch flags and libs') {
      @sut = TestableTarget.new { |t|
        t.name = 'sut'
        t.flags = [ 'a', [ 'b' ]]
        t.libs = [ 'x', @pkg, [ 'y', 'z']]
      }

      assert_equal('a b f1 f2', @sut.peek(:_flags))
      assert_equal('x l1 l2 y z', @sut.peek(:_libs))
    }

    should('dispatch dependencies') {
      @sut = TestableTarget.new { |t|
        t.name = 'sut'
        t.libs = [ 'x', @tar, @gen, @pkg, [ 'y', 'z']]
      }

      assert_equal(['|tar|'], @sut.peek(:_dependencies))
    }
  }

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
      assert_equal(FileList, @sut.peek(:_sources).class)
    }

    should('includes works with Rake::FileList') {
      assert_equal(String, @sut.peek(:_includes).class)
    }

    should('files works with Rake::FileList') {
      assert_equal(FileList, @sut.peek(:_files).class)
    }

    should('libs works with Rake::FileList') {
      assert_equal(String, @sut.peek(:_libs).class)
    }
  }
end

