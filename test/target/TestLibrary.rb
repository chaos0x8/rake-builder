require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder/target/Library'
require_relative 'Utils'

class TestLibrary < Test::Unit::TestCase
  context('TestLibrary') {
    setup {
      @sut = Library.new { |t|
        t.name = 'library'
        t.sources << 'foo.cpp'
      }
    }

    merge_block(&Utils.shouldSetDesc)
  }
end

