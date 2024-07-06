require 'pathname'
require 'fileutils'
require 'open3'

module Utils
  def capture(*args)
    out, st = Open3.capture2e(*args)
    [out.chomp, st]
  end
end

class Context
  attr_reader :work_dir, :name

  def initialize(path)
    @path = path.is_a?(Pathname) ? path : Pathname.new(path)
    @work_dir = @path.parent
    @name = @work_dir.basename.to_s
  end

  def use(rspec)
    s = self

    rspec.let :source_dir do
      s.work_dir
    end
  end
end

class ExampleContext < Context
  def describe(rspec, &block)
    s = self

    rspec.context 'rakefile' do
      include Utils

      s.use(self)

      before :all do
        Dir.chdir(s.work_dir) do
          out, st = capture 'rake', '-t', 'clean'
          expect(st.exitstatus).to be == 0, "Clean failed!\n#{out}"

          out, st = capture 'rake', '-t'
          expect(st.exitstatus).to be == 0, "Build failed!\n#{out}"
        end
      end

      let :work_dir do
        s.work_dir
      end

      instance_exec(&block)
    end
  end
end

class CmakeContext < Context
  def describe(rspec, &block)
    s = self

    rspec.context 'cmake' do
      include Utils

      s.use(self)

      before :all do
        Dir.chdir(s.work_dir) do
          out, st = capture 'rake', '-t', 'clean'
          expect(st.exitstatus).to be == 0, "Clean failed!\n#{out}"

          out, st = capture 'rake', '-t', 'cmake'
          expect(st.exitstatus).to be == 0, "Generate CMakeLists.txt failed!\n#{out}"

          FileUtils.rm_rf('build') if Pathname.new('build').exist?
          FileUtils.mkdir('build')

          Dir.chdir('build') do
            out, st = capture 'cmake', '..'
            expect(st.exitstatus).to be == 0, "cmake failed!\n#{out}"

            out, st = capture 'make'
            expect(st.exitstatus).to be == 0, "Build failed!\n#{out}"
          end
        end
      end

      let :work_dir do
        s.work_dir.join('build')
      end

      instance_exec(&block)
    end
  end
end

def example_describe(path, *tags, &block)
  context_list = []
  context_list << ExampleContext.new(path)

  while tag = tags.shift
    case tag
    when :cmake
      context_list << CmakeContext.new(path)
    else
      raise "Tag `#{tag.inspect}' not supported."
    end
  end

  RSpec.context "Example #{context_list.first.name}" do
    context_list.each do |ec|
      ec.describe(self, &block)
    end
  end
end
