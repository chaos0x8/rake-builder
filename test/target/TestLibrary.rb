require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder/target/Library'

class TestLibrary < Test::Unit::TestCase
  context('TestLibrary') {
    setup {
      @sut = Library.new { |t|
        t.name = 'library'
      }
    }

    [:desc=, :description=].each { |tag|
      should("set description/#{tag}") {
        sut = Library.new { |t|
          t.name = 'library'
          t.send(tag, 'foo')
        }

        assert_equal('foo', sut.description)
      }

      should("change description/#{tag}") {
        @sut.send(tag, 'foo')

        assert_equal('foo', @sut.description)
      }
    }
  }
end

