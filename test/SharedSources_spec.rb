gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../lib/rake-builder'

describe(SharedSources) {
  subject {
    SharedSources.new { |t|
      t.sources << '/tmp/main.cpp'
    }
  }

  let(:targetMock) {
    double('target')
  }

  TAGS = [:sources, :libs, :flags, :includes, :pkgs, :requirements]
  TAGS.each { |tag|
    it("responds to #{tag}") {
      should respond_to(tag)
    }
  }

  it("streams #{TAGS.join(', ')}") {
    TAGS.each { |tag|
      field = double(tag.to_s)

      allow(targetMock).to receive(tag).and_return(field)
      expect(field).to receive(:<<)
    }

    subject >> targetMock
  }

  [[:sources], [:flags, :libs], [:includes, :pkgs]].each_with_index { |tags, index|
    it("slices stream tags/#{index}") {
      tags.each { |tag|
        field = double(tag.to_s)

        allow(targetMock).to receive(tag).and_return(field)
        expect(field).to receive(:<<)
      }

      subject.slice(*tags) >> targetMock
    }
  }
}
