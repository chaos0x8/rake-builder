require 'pathname'
require 'open3'

class ExampleContext
  attr_reader :work_dir

  def initialize(path)
    @path = path.is_a?(Pathname) ? path : Pathname(path)
    @work_dir = @path.parent
    @name = @work_dir.basename.to_s
  end

  def describe(&block)
    s = self

    RSpec.context "Example #{@name}" do
      def capture(*args)
        out, st = Open3.capture2e(*args)
        [out.chomp, st]
      end

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

def example_describe(path, &block)
  ec = ExampleContext.new path
  ec.describe(&block)
end
