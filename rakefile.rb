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

require_relative 'lib/rake-builder'

require 'rubygems'

gemspec = Gem::Specification.load('rake-builder.gemspec')
gemFn = "rake-builder-#{gemspec.version}.gem"

rubyDev = InstallPkg.new(name: :rubyDev) { |t|
  t.pkgs << 'ruby-dev'
}

task(:installPkg) {
  require_pkg 'ruby-dev'
}

desc 'Runs unit tests'
task(:ut) {
  args = Dir['test/Test*.rb'].collect { |fn| ['-e', "require '#{File.expand_path(fn)}'"] }
  sh 'ruby', *args.flatten
}

desc 'Runs compilation tests'
task(:test => [gemFn, :ut]) {
  sh 'sudo', 'gem', 'install', '-l', gemFn

  Dir['examples/*'].each { |dir|
    Dir.chdir(dir) {
      sh 'rake', 'clean'
      sh 'rake'
    }
  }
}

desc 'Builds gem file'
file(gemFn => 'rake-builder.gemspec') {
  sh 'gem build rake-builder.gemspec'
  Dir['*.gem'].sort{ |a, b| File.mtime(a) <=> File.mtime(b) }[0..-2].each { |fn|
    FileUtils.rm(fn, verbose: true)
  }
}

desc 'Builds gem file'
task(:default => gemFn)

desc "Builds gem file"
task(:gem => gemFn)

['ArrayWrapper', 'Target', 'Generate'].each { |name|
  GeneratedFile.new { |t|
    t.desc = 'Generated file including directory'
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
  t.desc = 'Generates file including directory'
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
    content.flatten.join "\n"
  }
}
