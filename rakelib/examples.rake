require_relative '../lib/rake-builder/c8/Erb'
require_relative '../lib/rake-builder/c8/Data'

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
        C8.erb C8.data(__FILE__).rakefile
      }
    }
    files << GeneratedFile.new(format: true) { |t|
      t.name = File.join('examples', name, 'src', 'main.cpp')
      t.code = proc {
        C8.erb C8.data(__FILE__).main
      }
    }
    C8.task("new_#{name}" => Names[files])
    Rake::Task["new_#{name}"].invoke
  }
}

desc 'Compiles examples'
task(examples: 'examples:default')

__END__
@@rakefile=
gem 'rake-builder'

require 'rake-builder'

main = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << FileList['src/**/*.cpp']
  t.includes << 'src'
  t.flags << '--std=c++17'
}

task(default: Names[main])

task(:clean) {
  [RakeBuilder.outDir, 'lib', 'bin'].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
@@main=
#include <iostream>

int main(int argc, char** argv) {
  std::cout << "Hello world!\n";
}
