require_relative '../target/GeneratedFile'
require_relative '../Transform'
require_relative '../c8/Erb'
require_relative '../c8/Data'

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
          C8.erb C8.data(__FILE__).data, dir: dirName, includes: t.tracked
        }
      }
    }
  end
end

__END__
#pragma once

<%- @includes.each { |inc| -%>
#include "<%= File.join(@dir, inc) %>"
<%- } -%>
