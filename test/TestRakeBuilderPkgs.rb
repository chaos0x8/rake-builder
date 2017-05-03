#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2016 - 2017, <https://github.com/chaos0x8>
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

class TestPkgs < Test::Unit::TestCase
  def self.shouldReturn
    proc {
      should('returns flags') {
        assert_equal(Shellwords.split(`pkg-config --cflags ruby`), @flags.flatten)
      }

      should('returns libs') {
        assert_equal(Shellwords.split(`pkg-config --libs ruby`), @libs.flatten)
      }
    }
  end

  context('TestPkgs') {
    setup {
      @flags = Array.new
      @libs = Array.new
    }

    should('raises when pkg doesn\'t exists') {
      assert_raise(RakeBuilder::MissingPkg) {
        RakeBuilder::Pkgs.new('rubyfsdfsdf', flags: @flags, libs: @libs)
      }

      assert_equal([], @flags)
      assert_equal([], @libs)
    }

    context('created from existing pkg') {
      setup {
        @sut = RakeBuilder::Pkgs.new('ruby', flags: @flags, libs: @libs)
      }

      merge_block(&shouldReturn)
    }

    context('created from other pkg') {
      setup {
        @sut = RakeBuilder::Pkgs.new(
          RakeBuilder::Pkgs.new('ruby', flags: Array.new, libs: Array.new),
          flags: @flags,
          libs: @libs)
      }

      merge_block(&shouldReturn)
    }
  }
end

