namespace(:generated) {
  ['ArrayWrapper', 'Target', 'Generate', 'C8'].each { |name|
    GeneratedFile.new { |t|
      t.name = "lib/rake-builder/#{name}.rb"
      t.requirements = Dir["lib/rake-builder/#{name}/*.rb"]
      t.code = proc {
        t.requirements.collect { |fn|
          "require_relative '#{name}/#{File.basename(fn)}'"
        }.sort.join("\n")
      }
    }
  }

  GeneratedFile.new { |t|
    t.name = 'lib/rake-builder.rb'
    t.requirements << FileList['lib/rake-builder/*.rb']
    t.requirements << 'lib/rake-builder/ArrayWrapper.rb'
    t.requirements << 'lib/rake-builder/Target.rb'
    t.requirements << 'lib/rake-builder/Generate.rb'
    t.requirements << 'lib/rake-builder/C8.rb'
    t.code = proc {
      content = []
      content << "#!/usr/bin/env ruby"
      content << ""
      content << "autoload :Open3, 'open3'"
      content << "autoload :Shellwords, 'shellwords'"
      content << "autoload :FileUtils, 'fileutils'"
      content << ""
      content << "require 'rake'"
      content << ""
      content << Names[t.requirements].collect { |fn|
        "require_relative 'rake-builder/#{File.basename(fn)}'"
      }.sort
      content << ""
      content << "require_pkg 'pkg-config'"
      content.flatten.join "\n"
    }
  }

  desc 'Generates files'
  C8.task(all: 'lib/rake-builder.rb')
}
