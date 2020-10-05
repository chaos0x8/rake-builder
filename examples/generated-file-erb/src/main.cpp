#include "enum.hpp"
#include <iostream>

int main(int argc, char** argv) {
  std::cout << static_cast<std::underlying_type_t<Enumerable>>(Enumerable::a)
            << std::endl;
  std::cout << static_cast<std::underlying_type_t<Enumerable>>(Enumerable::b)
            << std::endl;
  std::cout << static_cast<std::underlying_type_t<Enumerable>>(Enumerable::c)
            << std::endl;
  std::cout << "Hello world!" << std::endl;
}
