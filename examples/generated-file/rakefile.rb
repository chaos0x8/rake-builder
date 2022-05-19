gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

C8.project 'demo' do
  file_generated 'src/hello.hpp' => __FILE__ do
    <<~INLINE
      #pragma once

      void hello();
    INLINE
  end

  file_generated 'src/hello.cpp' => __FILE__ do
    <<~INLINE
      #include <iostream>
      #include "hello.hpp"

      void hello() {
        std::cout << "Hello world!" << std::endl;
      }
    INLINE
  end

  file_generated 'src/main.cpp' => __FILE__ do
    <<~INLINE
      #include "hello.hpp"

      int main() {
        hello();
      }
    INLINE
  end

  executable 'bin/app' do
    sources << %w[src/hello.cpp src/main.cpp]
  end
end

desc 'Builds and executes application'
C8.task default: 'demo' do
  sh 'bin/app'
end

desc 'Removes build files'
C8.task clean: 'demo:clean'
