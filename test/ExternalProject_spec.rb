gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../lib/rake-builder'

RSpec.shared_examples('get_initialized') {
  context('.outDir') {
    it('get') {
      expect(subject.outDir).to eq 'dir/.obj'
      expect(subject.path).to eq 'dir/.obj/something'
    }
  }
}

describe(ExternalProject) {
  context('not initialized') {
    subject {
      ExternalProject.new { |t|
        t.name = 'c8'
        t.rakefile = 'rakefile.rb'
        t.git = 'something.git'
      }
    }

    context('.outDir') {
      it('get') {
        expect(subject.outDir).to eq RakeBuilder.outDir
        expect(subject.path).to eq File.join(RakeBuilder.outDir, 'something')
      }
    }
  }

  context('initialized via assign') {
    subject {
      ExternalProject.new { |t|
        t.name = 'c8'
        t.rakefile = 'rakefile.rb'
        t.git = 'something.git'
        t.outDir = 'dir/.obj'
      }
    }

    include_examples 'get_initialized'
  }

  context('initialized via args') {
    subject {
      ExternalProject.new(name: 'c8', rakefile: 'rakefile.rb', git: 'something.git', outDir: 'dir/.obj')
    }

    include_examples 'get_initialized'
  }
}

