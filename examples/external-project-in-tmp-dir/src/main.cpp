#include <c8-common.hpp>
#include <iostream>

int main(int argc, char** argv) {
  try {
    C8::Common::runtimeAssert(false, "assertion failed");
  } catch (const C8::Common::Errors::AssertionError&) {
    std::cout << "Hello world!" << std::endl;
  }
}
