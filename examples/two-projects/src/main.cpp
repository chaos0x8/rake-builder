#include <iostream>

#define MACRO_TO_STRING2(x) #x
#define MACRO_TO_STRING(x) MACRO_TO_STRING2(x)

int main(int argc, char** argv) {
  std::cout << "Project " << MACRO_TO_STRING(PROJECT_NAME) << std::endl;
}
