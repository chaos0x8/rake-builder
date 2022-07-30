gem 'rake-builder'

require 'rake-builder'

prints = { hello: 'Hello world!',
           bye: 'Bye!' }

demo = project do |p|
  p.generated_file 'src/hello.hpp' do |t|
    t.depend __FILE__

    t.erb = proc do
      <<~INLINE
        #pragma once

        <%- prints.each do |name, text| -%>
        void <%= name %>();
        <%- end -%>
      INLINE
    end
  end

  p.generated_file 'src/hello.cpp' do |t|
    t.depend __FILE__

    t.erb = proc do
      <<~INLINE
        #include <iostream>
        #include "hello.hpp"

        <%- prints.each do |name, text| -%>
        void <%= name %>() {
          std::cout << "<%= text %>" << std::endl;
        }
        <%- end -%>
      INLINE
    end
  end

  p.generated_file 'src/main.cpp' do |t|
    t.depend __FILE__

    t.erb = proc do
      <<~INLINE
        #include "hello.hpp"

        int main() {
          hello();
          bye();
        }
      INLINE
    end
  end

  p.executable 'bin/app' do |t|
    t.sources << %w[src/hello.cpp src/main.cpp]
  end
end

desc 'Builds and executes application'
multitask default: [*demo.requirements] do
  sh 'bin/app'
end

desc 'Removes build files'
task :clean do
  demo.clean
end
