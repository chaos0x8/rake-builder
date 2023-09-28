namespace(:examples) do
  task(default: 'gem:install') do
    examples = Pathname.pwd.glob(['examples/*/*_spec.rb'])
    system 'rspec', '-f', 'd', *examples.collect(&:to_s)
  end

  desc 'Generates template for new example'
  task(:new, [:name]) do |_t, args|
    name = args[:name]

    files = [].tap do |arr|
      tmp = RakeBuilder::Project.new

      arr.push(tmp.generated_file(File.join('examples', name, 'rakefile.rb')) do |t|
        t.erb = <<~INLINE
          gem 'rake-builder'

          require 'rake-builder'

          project = RakeBuilder::Project.new
          project.flags << %w[--std=c++17 -Isrc]

          project.executable 'bin/out' do |t|
            t.sources << Dir['src/**/*.cpp']
          end

          desc 'Compile'
          multitask compile: project.dependencies

          desc 'Compile'
          task default: :compile

          desc 'Clean'
          task :clean do
            project.clean
          end
        INLINE
      end)

      arr.push(tmp.generated_file(File.join('examples', name, 'src', 'main.cpp')) do |t|
        t.erb = <<~INLINE
          #include <iostream>

          int main(int argc, char** argv) {
            std::cout << "Hello world!\\n";
          }
        INLINE
      end)

      arr.push(tmp.generated_file(File.join('examples', name, 'package_spec.rb')) do |t|
        t.erb = <<~INLINE
          require_relative '../../tests/examples_base'

          example_describe __FILE__ do
            it 'Executes and produces correct output' do
              out, st = Open3.capture2e(work_dir.join('bin/out').to_s)

              aggregate_failures do
                expect(st.exitstatus).to be == 0
                expect(out.chomp).to be == 'Hello world!'
              end
            end
          end
        INLINE
      end)
    end

    task("new_#{name}" => files.collect { |x| x.path.to_s })
    Rake::Task["new_#{name}"].invoke
  end
end

desc 'Compiles examples'
task(examples: 'examples:default')
