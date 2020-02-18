#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2017, <https://github.com/chaos0x8>
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

require_relative '../lib/rake-builder/RakeGenerate'

class TestRakeGenerateIncludeDirectory < Test::Unit::TestCase
  context('TestRakeGenerateIncludeDirectory') {
    setup {
      @gf = mock
      @req = mock
    }

    should('create generated file') {
      GeneratedFile.expects(:new).yields(@gf).returns(@gf)
      @gf.expects(:name=).with('path/directory.hpp')
      @gf.expects(:code=)
      @gf.expects(:requirements).returns(@req).at_least(1)
      @req.expects(:<<).at_least(1)

      assert_equal(@gf, Generate::includeDirectory('path/directory'))
    }
  }
end


