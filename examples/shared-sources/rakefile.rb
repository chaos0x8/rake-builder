gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

install = InstallPkg.new(name: :install, pkgs: ['ruby-dev'])

sources = SharedSources.new { |t|
  t.sources << Dir['Source/*.cpp'] - ['Source/main.cpp']
  t.flags << ['--std=c++17']
  t.includes << ['Source']
  t.pkgs << ['ruby']
  t.requirements << install
}

main = SharedSources.new { |t|
  t.sources << 'Source/main.cpp'
  t.flags << ['--std=c++17']
  t.includes << ['Source']
  t.pkgs << ['ruby']
  t.requirements << install
}

lib = Library.new { |t|
  t.name = 'lib/libmain.a'
  t.desc = 'Build testable library'

  sources.slice(:sources, :flags, :pkgs, :includes) >> t
}

app = Executable.new { |t|
  t.name = 'bin/main'
  t.sources << main
  t.libs << ['-lpthread', lib]
  t.pkgs << ['ruby']
  t.desc = 'Build testable application'
}

app_without_lib = Executable.new { |t|
  t.name = 'bin/main_without_lib'
  t.libs << ['-lpthread']
  t.desc = 'Build testable application'

  main.slice(:sources, :pkgs) >> t
  sources >> t
}

multitask(default: Names[app, app_without_lib])

task(:clean) {
  [ 'lib', 'bin', RakeBuilder.outDir ].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
