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

class TestSourceFile < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestSourceFile') {
    setup {
      File.expects(:exist?).returns(false).at_least(0)

      @seq = sequence('rule sequence')
    }

    should('raise when name is not provided') {
      assert_raise(RakeBuilder::MissingAttribute) {
        RakeBuilder::SourceFile.new(
          flags: [ '--std=c++11' ],
          includes: [ 'Source' ]
        )
      }
    }

    should('create build rule') {
      RakeBuilder::SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).with { |x| x.keys.first == to_mf(t.name) }.in_sequence(@seq)
        t.expects(:file).with { |x| x.keys.first == to_obj(t.name) }.in_sequence(@seq)
      }
    }

    should('read dependencies before creating rules') {
      RakeBuilder::SourceFile.new { |t|
        t.name = 'main.cpp'

        File.expects(:exist?).with(to_mf(t.name)).returns(true).at_least(0)
        File.expects(:open).with(to_mf(t.name), 'r').returns(['file1']).at_least(0)

        t.expects(:file).with { |x| x.values.first.include?('file1') }.in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('include dependency to .obj directory') {
      RakeBuilder::SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).with { |x| x.values.first.include?('.obj') }.in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('describe rule') {
      RakeBuilder::SourceFile.new { |t|
        t.name = 'main.cpp'
        t.description = 'desc'

        t.expects(:file).in_sequence(@seq)
        t.expects(:desc).with(t.description).in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('be converted by Names') {
      source = RakeBuilder::SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).at_least(0)
      }

      assert_equal([to_obj('main.cpp')], Names[source])
    }
  }
end
