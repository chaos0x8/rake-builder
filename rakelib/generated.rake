require_relative '../lib/rake-builder/target/GeneratedFile'
require_relative '../lib/rake-builder/c8/task'

namespace(:generated) {
  generated = Dir['lib/rake-builder/*'].select { |dir|
    File.directory?(dir)
  }.collect { |dir|
    GeneratedFile.new { |t|
      t.name = "#{dir}.rb"
      t.track FileList[File.join(dir, '*.rb')]
      t.code = proc { |dst|
        $stdout.puts "Generating #{dst} ..."

        t.tracked.collect { |fn|
          "require_relative '#{File.basename(dir)}/#{File.basename(fn)}'"
        }.sort.join("\n")
      }
    }
  }

  GeneratedFile.new { |t|
    t.name = 'lib/rake-builder.rb'
    t.requirements << Names[generated]
    t.track :requirements
    t.track FileList['lib/rake-builder/*.rb']
    t.code = proc { |dst|
      $stdout.puts "Generating #{dst} ..."

      content = []
      content << "#!/usr/bin/env ruby"
      content << ""
      content << "autoload :Open3, 'open3'"
      content << "autoload :Shellwords, 'shellwords'"
      content << "autoload :FileUtils, 'fileutils'"
      content << ""
      content << "require 'rake'"
      content << ""
      content << Names[t.tracked].collect { |fn|
        "require_relative 'rake-builder/#{File.basename(fn)}'"
      }.sort
      content << ""
      content << "require_pkg 'pkg-config'"
      content.flatten.join "\n"
    }
  }

  C8.task(default: 'lib/rake-builder.rb')
}
