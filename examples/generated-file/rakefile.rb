gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

hello_hpp = GeneratedFile.new { |t|
  t.name = 'src/hello.hpp'
  t.requirements << 'rakefile.rb'
  t.action = proc { |fn|
    c = [ '#pragma once',
          '',
          'void hello();' ]
    IO.write(fn, c.join("\n"))
  }
}

hello_cpp = GeneratedFile.new(format: true) { |t|
  t.name = 'src/hello.cpp'
  t.requirements << 'rakefile.rb'
  t.code = proc {
    [ '#include <iostream>',
      '#include "hello.hpp"',
      '',
      'void hello() {',
      '  std::cout << "Hello world!" << std::endl;',
      '}']
  }
}

main = GeneratedFile.new(format: true) { |t|
  t.name = 'src/main.cpp'
  t.requirements << 'rakefile.rb'
  t.code = proc {
    [ '#include "hello.hpp"',
      '',
      'int main() {',
      'hello();',
      '}']
  }
}

generate = Invoke.new { |t|
  t.name = :generate
  t.requirements << [main, hello_hpp, hello_cpp]
}

app = Executable.new { |t|
  t.name = 'bin/app'
  t.requirements << generate
  t.sources << Names[main, hello_cpp]
}

multitask(default: Names[app])

task(:clean) {
  Names[RakeBuilder.outDir, 'bin', main, hello_hpp, hello_cpp].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}

