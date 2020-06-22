# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2017, <https://github.com/chaos0x8>
#
# \copyright
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# \copyright
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require_relative '../GeneratedFile'
require_relative '../Transform'

module Generate
  extend RakeBuilder::Transform

  def includeDirectory(dirName, requirements: [])
    GeneratedFile.new { |t|
      t.name = "#{dirName}.hpp"

      dir = Names[Directory.new(name: t.name)]
      cl = RakeBuilder::ComponentList.new(
        name: to_cl(t.name),
        sources: Dir["#{dirName}/*.h", "#{dirName}/*.hpp"],
        rebuild: [:missing])

      t.requirements << requirements
      t.requirements << Names[cl]
      t.code = proc {
        $stdout.puts "Generating '#{t.name}'..."

        File.open(t.name, 'w') { |f|
          f.write "#pragma once\n"
          f.write "\n"
          Dir["#{dirName}/*.h", "#{dirName}/*.hpp"].each { |req|
            f.write "#include \"#{File.basename(dirName)}/#{File.basename(req)}\"\n"
          }
        }
      }
    }
  end

  module_function :includeDirectory
end

