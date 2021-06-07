require_relative '../target/GeneratedFile'
require_relative '../Transform'
require_relative '../c8/Erb'

TEMPLATE_INCLUDE_DIRECTORY = <<INLINE
#pragma once

<%- @includes.each { |inc| -%>
#include "<%= File.join(@dir, File.basename(inc)) %>"
<%- } -%>
INLINE

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
          C8.erb TEMPLATE_INCLUDE_DIRECTORY, dir: File.basename(dirName), includes: t.tracked
        }
      }
    }
  end
end
