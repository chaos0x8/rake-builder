namespace(:examples) {
  task(:default => 'gem:install') {
    separator = '---------------------'
    info = []

    Dir['examples/*'].each { |dir|
      Dir.chdir(dir) {
        $stdout.puts separator
        $stdout.puts "Example: #{File.basename(dir)}"
        $stdout.puts separator
        sh 'rake', 'clean'
        sh 'rake'
        info << "Example: #{File.basename(dir)} => OK"
      }
    }

    $stdout.puts separator
    $stdout.puts info
    $stdout.puts separator
  }

  desc 'Generates template for new example'
  task(:new, [:name]) { |t, args|
    name = args[:name]

    files = []
    files << GeneratedFile.new { |t|
      t.name = File.join('examples', name, 'rakefile.rb')
      t.code = proc {
        d = []
        d << "gem 'rake-builder'"
        d << ""
        d << "require 'rake-builder'"
        d << ""
        d << "main = Executable.new { |t|"
        d << "  t.name = 'bin/main'"
        d << "  t.sources << FileList['src/**/*.cpp']"
        d << "  t.includes << 'src'"
        d << "  t.flags << '--std=c++17'"
        d << "}"
        d << ""
        d << "task(default: Names[main])"
        d << ""
        d << "task(:clean) {"
        d << "  [RakeBuilder.outDir, 'lib', 'bin'].each { |fn|"
        d << "    FileUtils.rm_rf fn, verbose: true if File.directory?(fn)"
        d << "  }"
        d << "}"
      }
    }
    files << GeneratedFile.new(format: true) { |t|
      t.name = File.join('examples', name, 'src', 'main.cpp')
      t.code = proc {
        d = []
        d << "#include <iostream>"
        d << ""
        d << "int main(int argc, char** argv) {"
        d << "  std::cout << \"Hello world!\" << std::endl;"
        d << "}"
      }
    }
    C8.task("new_#{name}" => Names[files])
    Rake::Task["new_#{name}"].invoke
  }
}

desc 'Compiles examples'
task(examples: 'examples:default')
