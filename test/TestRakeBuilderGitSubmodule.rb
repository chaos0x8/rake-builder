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

class TestGitSubmodule < Test::Unit::TestCase
  def expectInvoke taskName
    mockObj = mock()
    Rake::Task.expects(:[]).with(taskName).returns(mockObj).at_least(0)
    mockObj.expects(:invoke)
  end

  context('TestGitSubmodule') {
    setup {
      @seq = sequence('rule sequence')

      File.expects(:directory?).returns(false).at_least(0)

      mockObj = mock()
      Rake::Task.expects(:[]).returns(mockObj).at_least(0)
      mockObj.expects(:invoke).at_least(0)
    }

    should('init git submodule') {
      expectInvoke 'cppCommon/lib/libcommon.a'

      GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a']) { |t|
        t.expects(:file).with('cppCommon/.git')
        t.expects(:file).with('cppCommon/lib/libcommon.a' => [ 'cppCommon/.git' ])
      }
    }

    should('raise when name is missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        GitSubmodule.new(libs: ['lib/libcommon.a']) { |t|
          t.expects(:file).never
        }
      }
    }

    should('raise when libs are missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        GitSubmodule.new(name: 'cppCommon') { |t|
          t.expects(:file).never
        }
      }
    }

    should('be converted by Names') {
      git = GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a', 'lib/libfoo.a']) { |t|
        t.expects(:file).at_least(0)
      }
      assert_equal(['cppCommon/lib/libcommon.a', 'cppCommon/lib/libfoo.a'], Names[git])
    }

    should('create file rules') {
      GitSubmodule.new(name: 'cppCommon', libs: ['lib/libcommon.a', 'lib/libfoo.a']) { |t|
        t.expects(:file).with('cppCommon/.git')
        t.expects(:file).with('cppCommon/lib/libcommon.a' => [ 'cppCommon/.git' ])
        t.expects(:file).with('cppCommon/lib/libfoo.a' => [ 'cppCommon/.git' ])
      }
    }
  }
end

