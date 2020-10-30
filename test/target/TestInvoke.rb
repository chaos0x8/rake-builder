require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder/target/Invoke'
require_relative 'Utils'

class TestInvoke < Test::Unit::TestCase
  context('TestInvoke') {
    setup {
      @sut = Invoke.new { |t|
        t.name = 'library'
        t.requirements << 'task1' << :task2
      }
    }

    merge_block(&Utils.shouldSetDesc)
    merge_block(&Utils.shouldSetReqs)
  }
end


