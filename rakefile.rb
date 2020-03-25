#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2015 - 2016, <https://github.com/chaos0x8>
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

require 'rake/testtask'

require_relative 'lib/rake-builder'

rubyDev = InstallPkg.new(name: :rubyDev) { |t|
  t.pkgs << 'ruby-dev'
}

task(:installPkg) {
  require_pkg 'ruby-dev'
}

Rake::TestTask.new(test: Names[rubyDev]) { |t|
  t.pattern = "#{File.dirname(__FILE__)}/test/Test*.rb"
}

desc "#{File.basename(File.dirname(__FILE__))}"
task(:default => :test)

desc "builds gem file"
task(:gem => 'rake-builder.gemspec') {
  sh 'gem build rake-builder.gemspec'
  Dir['*.gem'].sort{ |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each { |fn|
    FileUtils.rm(fn, verbose: true)
  }
}

['ArrayWrapper', 'Target', 'Generate'].each { |name|
  GeneratedFile.new { |t|
    t.name = "lib/rake-builder/#{name}.rb"
    t.requirements = Dir["lib/rake-builder/#{name}/*.rb"]
    t.code = proc {
      content = t.requirements.collect { |fn|
        "require_relative '#{name}/#{File.basename(fn)}'"
      }.sort.join("\n")

      IO.write(t.name, content)
    }
  }
}

GeneratedFile.new { |t|
  t.description = 'Generates file including directory'
  t.name = 'lib/rake-builder.rb'
  t.requirements << FileList['lib/rake-builder/*.rb'] 
  t.requirements << 'lib/rake-builder/ArrayWrapper.rb'
  t.requirements << 'lib/rake-builder/Target.rb'
  t.requirements << 'lib/rake-builder/Generate.rb'
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

    IO.write(t.name, content.flatten.join("\n"))
  }
}
