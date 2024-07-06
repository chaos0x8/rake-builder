gem 'rake-builder'

require 'rake-builder'

project = RakeBuilder::Project.new flags_compile: %w[--std=c++17 -Isrc]
project.generate path: 'src/value0.hpp',
                 text: <<~TEXT
                   #pragma once

                   constexpr auto value0 = 42;
                 TEXT
project.generate path: 'src/value1.hpp',
                 data: { val: 70 },
                 text: <<~TEXT
                   #pragma once

                   constexpr auto value1 = <%= val %>;
                 TEXT
project.executable path: 'bin/out',
                   sources: Dir['src/**/*.cpp'],
                   depend: project.generated
project.configure_cmake
project.define_tasks
