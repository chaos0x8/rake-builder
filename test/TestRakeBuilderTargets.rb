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
require_relative 'Stubs/SourceFileStub'

class TestTargets < Test::Unit::TestCase
  context('TestTargets') {
    setup {
      @sources = [ 'main.cpp' ]
      RakeBuilder::SourceFile.expects(:new).at_least(0)
    }

    [
      [ symbol: :includes,  input: [['inc1'], ['inc2']], output: [ '-Iinc1', '-Iinc2' ] ],
      [ symbol: :flags,  input: [['flag1', '-std=c++11'], ['flag2', '--std=c++14']], output: [ 'flag1', 'flag2', '--std=c++14' ] ],
      [ symbol: :libs,  input: [['lib1'], ['lib2']], output: [ 'lib1', 'lib2' ] ],
      [ symbol: :requirements,  input: [['req1'], ['req2']], output: [ 'req1', 'req2' ], collect: Names ]
    ].each { |symbol:, input:, output:, collect: Build|
      should("be able to use #{symbol} from other target") {
        target1 = Executable.new(name: 'target1') { |t|
          t.expects(:file).at_least(0)

          t.send(symbol) << input.first
          t.sources << @sources
        }

        target2 = Executable.new(name: 'target2') { |t|
          t.expects(:file).at_least(0)

          t.send(symbol) << target1.send(symbol) << input.last
          t.sources << @sources
        }

        assert_equal(output.sort, collect[target2.send(symbol)].sort)
      }
    }
  }

  context('TestTargets with stub sources') {
    setup {
      @sources1 = [ 'source1-a', 'source1-b', 'source1-c' ]
      @sources2 = [ 'source2' ]

      (@sources1+@sources2).each { |src|
        stub = SourceFileStub.new(name: src)
        stub.expects(:kind_of?).returns(false).at_least(0)
        stub.expects(:kind_of?).with(RakeBuilder::SourceFile).returns(true).at_least(0)
        RakeBuilder::SourceFile.expects(:new).with { |name:, **opts| name == src }.returns(stub).at_least(0)
      }
    }

    should("be able to use sources from other target") {
      target1 = Executable.new(name: 'target1') { |t|
        t.expects(:file).at_least(0)

        t.sources << @sources1
      }

      target2 = Executable.new(name: 'target2') { |t|
        t.expects(:file).at_least(0)

        t.sources << target1.sources - ['source1-b'] << @sources2
      }

      assert_equal(['source1-a', 'source1-c', 'source2'].sort, Names[target2.sources].sort)
    }
  }
end

