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

class TestGeneratedFile < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestGeneratedFile') {
    setup {
      @seq = sequence('rule sequence')
    }

    should('create file rule') {
      GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.code = proc { |fileName|
          File.open(fileName, 'w') { |file|
            file.write 'xxx'
          }
        }

        t.expects(:file).with(t.name => ['path'])
      }
    }

    should('create file rule with description') {
      GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.description = 'desc'
        t.code = proc { |fileName| }

        t.expects(:description).with(t.description).in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('be converted by Names') {
      gen = GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.code = proc { |fileName| }

        t.expects(:file).at_least(0)
      }

      assert_equal(['path/main.cpp'], Names[gen])
    }
  }
end

