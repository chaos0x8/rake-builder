#include <iostream>
#include <ruby.h>

struct RubyInit {
  RubyInit() {
    ruby_init();
  }

  ~RubyInit() {
    ruby_cleanup(0);
  }
};

int main(int argc, char** argv) {
  RubyInit init;

  std::cout << "Hello world!\n";
}
