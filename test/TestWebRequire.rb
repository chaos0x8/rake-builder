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

require_relative '../lib/WebRequire'

class TestWebRequire < Test::Unit::TestCase
    include RakeBuilder

    def expect_spawn_process
        @pid = 42

        Process.expects(:spawn).with('wget', @url).returns(@pid).in_sequence(@seq).then(@st.is('spawned'))
        Process.expects(:wait).with(@pid).in_sequence(@seq)
    end

    def expect_kill_spawned_process
        expect_spawn_process.raises(Interrupt.new)
        Process.expects(:kill).with('TERM', @pid).in_sequence(@seq)
        Process.expects(:wait).with(@pid).in_sequence(@seq)
    end

    context('TestWebRequire') {
        setup {
            Process.expects(:spawn).at_most(0)
            Process.expects(:wait).at_most(0)
            Process.expects(:kill).at_most(0)
            FileUtils.expects(:rm).at_most(0)
            self.expects(:require_relative).at_most(0)
        }

        setup {
            @seq = sequence('sequence')
            @st = states('process').starts_as('none')
        }

        setup {
            @url = 'http://some-long/nested/url/to/filename.rb'
            @file = 'filename.rb'
        }

        should('not download whet file exists') {
            File.expects(:exists?).with(@file).returns(true).at_least(0)
            self.expects(:require_relative).with(@file)

            web_require @url
        }

        should('download befor require') {
            expect_spawn_process

            self.expects(:require_relative).with(@file).in_sequence(@seq)

            web_require @url
        }

        should('interrupt download') {
            expect_kill_spawned_process

            assert_raise(Interrupt) {
                web_require @url
            }
        }

        should('clean after interrupted download') {
            expect_kill_spawned_process

            File.expects(:exists?).with(@file).when(@st.is('none')).returns(false).at_least(0)
            File.expects(:exists?).with(@file).when(@st.is('spawned')).returns(true).at_least(0)

            FileUtils.expects(:rm).with(@file)

            assert_raise(Interrupt) {
                web_require @url
            }
        }
    }
end
