namespace(:examples) do
  task(default: 'gem:install') do
    separator = '---------------------'
    info = []

    Dir['examples/*'].each do |dir|
      Dir.chdir(dir) do
        $stdout.puts separator
        $stdout.puts "Example: #{File.basename(dir)}"
        $stdout.puts separator
        sh 'rake', 'clean'
        sh 'rake'
        info << "Example: #{File.basename(dir)} => OK"
      end
    end

    $stdout.puts separator
    $stdout.puts info
    $stdout.puts separator
  end

  desc 'Generates template for new example'
  task(:new, [:name]) do |_t, args|
    name = args[:name]

    files = [].tap do |arr|
      arr.push(generated_file(File.join('examples', name, 'rakefile.rb')) do |t|
        t.depend __FILE__
        t.erb = <<~INLINE
          gem 'rake-builder'

          require 'rake-builder'

          demo = project do |p|
            p.flags << %w[--std=c++17 -Isrc]

            p.executable 'bin/demo' do |t|
              t.sources << Dir['src/**/*.cpp']
            end
          end

          desc 'Build task'
          multitask default: [*demo.requirements] do
            sh 'bin/demo'
          end

          desc 'Clean task'
          task :clean do
            demo.clean
          end
        INLINE
      end)

      arr.push(generated_file(File.join('examples', name, 'src', 'main.cpp')) do |t|
        t.depend __FILE__
        t.erb = <<~INLINE
          #include <iostream>

          int main(int argc, char** argv) {
            std::cout << "Hello world!\\n";
          }
        INLINE
      end)
    end

    task("new_#{name}" => files.collect { |x| x.path.to_s })
    Rake::Task["new_#{name}"].invoke
  end
end

desc 'Compiles examples'
task(examples: 'examples:default')
