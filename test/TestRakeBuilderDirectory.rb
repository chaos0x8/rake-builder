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

class TestDirectory < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestDirectory') {
    should('create rule') {
      Directory.new(name: 'path-1/fn.cpp') { |t|
        t.expects(:directory).with('path-1')
      }
    }

    should('not create same directory multiple times') {
      Directory.new(name: 'path-2/fn-1.cpp') { |t|
        t.expects(:directory).with('path-2')
      }

      Directory.new(name: 'path-2/fn-2.cpp') { |t|
        t.expects(:directory).at_most(0)
      }
    }

    should('be converted by Names') {
      dir = Directory.new(name: 'path-3/fn-3.cpp') { |t|
        t.expects(:directory).at_least(0)
      }

      assert_equal(['path-3'], Names[dir])
    }

    should('be converted by Names to empty when is eq to current directory') {
      dir = Directory.new(name: 'fn-4') { |t|
        t.expects(:directory).at_least(0)
      }

      assert_equal([], Names[dir])
    }
  }
end

