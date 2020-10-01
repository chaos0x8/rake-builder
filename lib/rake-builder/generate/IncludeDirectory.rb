require_relative '../target/GeneratedFile'
require_relative '../Transform'

module Generate
  extend RakeBuilder::Transform

  def self.includeDirectory(dirName, requirements: [])
    GeneratedFile.new(format: true) { |t|
      t.name = "#{dirName}.hpp"

      dir = Names[Directory.new(t.name)]

      t.track Dir["#{dirName}/*.h", "#{dirName}/*.hpp"]
      t.requirements << requirements
      t.code = proc {
        $stdout.puts "Generating '#{t.name}'..."

        File.open(t.name, 'w') { |f|
          d = []
          d << "#pragma once"
          d << ""
          t.tracked.each { |req|
            d << "#include \"#{File.basename(dirName)}/#{File.basename(req)}\""
          }
          d.join "\n"
        }
      }
    }
  end
end

