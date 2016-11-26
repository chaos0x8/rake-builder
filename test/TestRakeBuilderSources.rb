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
require_relative 'Stubs/SourceFileStub'

class TestSources < Test::Unit::TestCase
  context('TestSources') {
    setup {
      @sources = [ 'source1', 'source2', 'source3' ]
      @sources.each { |src|
        stub = SourceFileStub.new(name: src)
        stub.expects(:kind_of?).returns(false).at_least(0)
        stub.expects(:kind_of?).with(SourceFile).returns(true).at_least(0)
        SourceFile.expects(:new).with { |name:, **opts| name == src }.returns(stub).at_least(0)
      }

      @opts = { flags: [], includes: [], requirements: [] }
    }

    should('return copy of self without specified element') {
      sut = RakeBuilder::Sources.new(@sources, **@opts)

      result = sut - [ 'source2' ]

      assert(result.class == Array)
      assert_equal(['source1', 'source3'].sort, RakeBuilder::Names[result].sort)
    }
  }
end

