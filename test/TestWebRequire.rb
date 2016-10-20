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
  context('TestWebRequire') {
    setup {
      @url = 'https://raw.githubusercontent.com/chaos0x8/rake-builder/master/lib/FileName.rb'
      @path = File.expand_path('../lib', File.dirname(__FILE__))
    }

    context('.web_require') {
      setup {
        File.expects(:exists?).returns(false).at_least(0)
        self.expects(:system).at_most(0)
      }

      should('download file it doesn\'t exists') {
        self.expects(:system).with('wget', @url)
        self.expects(:require).with("#{@path}/FileName.rb")

        web_require(@url)
      }

      should('not download when file already exists') {
        File.expects(:exists?).with("#{@path}/FileName.rb").returns(true).at_least(0)
        self.expects(:require).with("#{@path}/FileName.rb")

        web_require(@url)
      }
    }

    context('.web_eval') {
      setup {
        require 'open3'
      }

      should('source file from web') {
        Open3.expects(:capture2).returns(['code', 'capture_status']).at_least(0)
        self.expects(:eval).with('code')
        web_eval('https://raw.githubusercontent.com/chaos0x8/rake-builder/master/lib/RakeBuilder.rb')
      }
    }
  }
end
