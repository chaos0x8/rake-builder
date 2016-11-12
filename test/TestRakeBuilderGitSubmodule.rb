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

class TesGitSubmodule < Test::Unit::TestCase
  context('TesGitSubmodule') {
    setup {
      @seq = sequence('rule sequence')

      File.expects(:directory?).returns(false).at_least(0)
    }

    should('init git submodule') {
      GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a']) { |t|
        t.expects(:sh).with('git submodule init').in_sequence(@seq)
        t.expects(:sh).with('git submodule update').in_sequence(@seq)
        t.expects(:file).at_least(0).in_sequence(@seq)
      }
    }

    should('raise when name is missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        GitSubmodule.new(libs: ['lib/libcommon.a']) { |t|
          t.expects(:sh).at_most(0)
        }
      }
    }

    should('raise when libs are missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        GitSubmodule.new(name: 'cppCommon') { |t|
          t.expects(:sh).at_most(0)
        }
      }
    }

    should('be converted by Names') {
      git = GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a', 'lib/libfoo.a']) { |t|
        t.expects(:sh).at_least(0)
        t.expects(:file).at_least(0)
      }
      assert_equal(['cppCommon/lib/libcommon.a', 'cppCommon/lib/libfoo.a'], RakeBuilder::Names[git])
    }

    context('with module initialized') {
      setup {
        File.expects(:directory?).with('cppCommon/.git').returns(true).at_least(0)
      }

      should('not init git submodule') {
        GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a']) { |t|
          t.expects(:sh).at_most(0)
          t.expects(:file).at_least(0)
        }
      }

      should('create file rules') {
        GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a', 'lib/libfoo.a']) { |t|
          t.expects(:sh).at_most(0)

          t.expects(:file).with { |x| x.keys.first == 'cppCommon/lib/libcommon.a' }
          t.expects(:file).with { |x| x.keys.first == 'cppCommon/lib/libfoo.a' }
        }
      }
    }
  }
end

