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

class TestRakeBuilderGitSubmodule < Test::Unit::TestCase
    context('TestRakeBuilderGitSubmodule') {
        setup {
            @objects = Array.new

            seq = sequence('GitSubmodule.new')

            2.times {
                object = Object.new
                GitSubmodule.expects(:new).yields(object).returns(object).in_sequence(seq)
                @objects << object
            }
        }

        should('create multiple submodules') {
            @objects[0].expects(:name=).with('name1')
            @objects[0].expects(:libs=).with(['library1', 'library2'])
            @objects[1].expects(:name=).with('name2')
            @objects[1].expects(:libs=).with(['library3', 'library4'])

            assert_equal(@objects, GitSubmodule['name1' => [ 'library1', 'library2' ],
                                                'name2' => [ 'library3', 'library4' ]])
        }
    }
end

