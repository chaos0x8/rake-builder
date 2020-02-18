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

class TestArrayWrappers < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestArrayWrappers') {
    {
      RakeBuilder::Includes => { exception: [ :_names_ ], noException: [ :_build_ ] },
      RakeBuilder::Sources => { noException: [ :_names_ ], noMethod: [ :_build_ ] },
      RakeBuilder::Libs => { noException: [ :_names_, :_build_ ] },
      RakeBuilder::Pkgs => { exception: [ :_names_, :_build_ ] },
      RakeBuilder::Requirements => { exception: [ :_build_ ], noException: [ :_names_ ] }
    }.each { |_class_, _tests_|
      context("#{_class_}") {
        if _class_ == RakeBuilder::Sources
          setup {
            @sut = _class_.new([], flags: [], includes: [], requirements: [])
          }
        elsif _class_ == RakeBuilder::Pkgs
          setup {
            @sut = _class_.new([], flags: [], libs: [])
          }
        else
          setup {
            @sut = _class_.new([])
          }
        end

        (_tests_[:exception] || []).each { |_symbol_|
          should("raise when '#{_symbol_}' called") {
            assert_raise(TypeError) {
              @sut.send(_symbol_)
            }
          }
        }

        (_tests_[:noException] || []).each { |_symbol_|
          should("not raise when '#{_symbol_}' called") {
            @sut.send(_symbol_)
          }
        }

        (_tests_[:noMethod] || []).each { |_symbol_|
          should("not respond to '#{_symbol_}'") {
            assert_equal(false, @sut.respond_to?(_symbol_))
          }
        }
      }
    }
  }
end

