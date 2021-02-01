gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../lib/rake-builder'

RSpec.configure do |config|
  config.mock_with :mocha
end

describe(SharedSources) {
  subject {
    SharedSources.new { |t|
      t.sources << '/tmp/main.cpp'
    }
  }

  let(:targetMock) { mock('target') }

  TAGS = [:sources, :libs, :flags, :includes, :pkgs, :requirements]
  TAGS.each { |tag|
    it("responds to #{tag}") {
      should respond_to(tag)
    }
  }
  it("streams #{TAGS.join(', ')}") {
    TAGS.each { |tag|
      field = mock(tag.to_s)
      targetMock.expects(tag).returns(field)
      field.expects(:<<).with(anything)
    }

    subject >> targetMock
  }

  [[:sources], [:flags, :libs], [:includes, :pkgs]].each_with_index { |tags, index|
    it("slices stream tags/#{index}") {
      tags.each { |tag|
        field = mock(tag.to_s)
        targetMock.expects(tag).returns(field)
        field.expects(:<<).with(anything)
      }

      subject.slice(*tags) >> targetMock
    }
  }
}
