require 'rake'

require_relative '../../lib/rake-builder/project/project'
require_relative '../../lib/rake-builder/project/library_static'
require_relative '../../lib/rake-builder/project/executable'

describe RakeBuilder::Project do
  RSpec::Matchers.define :object_id_be do
    chain :== do |expected|
      @expected = expected
    end

    description do
      "object_id to be == #{@expected}"
    end

    match do
      actual.object_id == @expected
    end

    failure_message do
      "expected #{actual.class}.object_id to be == #{@expected}, but it is #{actual.object_id}"
    end

    failure_message_when_negated do
      "expected #{actual.class}.object_id to be != #{@expected}, but it is #{actual.object_id}"
    end
  end

  context 'Executable linking to LibraryStatic' do
    before do
      @project = RakeBuilder::Project.new
      @library_static = @project.library_static path: 'lib/xyz.a',
                                                flags_compile: %w[-Isrc]
      @executable = @project.executable path: 'bin/out',
                                        flags_link: %w[lib/xyz.a]
    end

    it 'project is able to find library by path' do
      expect(@project.find_library('lib/xyz.a')).to object_id_be == @library_static.object_id
    end

    it 'executable inheritet library compile flags' do
      expect(@executable.flags_compile.to_a).to contain_exactly(*%w[-Isrc])
    end
  end
end
