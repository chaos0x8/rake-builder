require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/rake-builder'

class TestSharedSources < Test::Unit::TestCase
  TAGS = [:sources, :libs, :flags, :includes, :pkgs, :requirements]

  context('TestSharedSources') {
    setup {
      @mock = mock('mock')

      @sut = SharedSources.new { |t|
        t.sources << '/tmp/main.cpp'
      }
    }

    TAGS.each { |tag|
      should("respond to #{tag}") {
        assert(@sut.respond_to?(tag))
      }
    }

    should("stream tags") {
      TAGS.each { |tag|
        field = mock(tag.to_s)
        @mock.expects(tag).returns(field)
        field.expects(:<<).with(anything)
      }

      @sut >> @mock
    }

    [[:sources], [:flags, :libs], [:includes, :pkgs]].each_with_index { |tags, index|
      should("slice stream tags/#{index}") {
        tags.each { |tag|
          field = mock(tag.to_s)
          @mock.expects(tag).returns(field)
          field.expects(:<<).with(anything)
        }

        @sut.slice(*tags) >> @mock
      }
    }
  }
end


