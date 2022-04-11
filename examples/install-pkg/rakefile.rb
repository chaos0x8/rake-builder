gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

install = InstallPkg.new(name: :install, pkgs: ['ruby-dev'])

libs = []

libs << Library.new do |t|
  t.name = 'lib/libmain.a'
  t.requirements << install
  t.sources << Dir['Source/*.cpp'] - ['Source/main.cpp']
  t.includes << ['Source']
  t.flags << ['--std=c++0x']
  t.pkgs << ['ruby']
  t.description = 'Build testable library'
end

main = Executable.new do |t|
  t.name = 'bin/main'
  t.requirements << install
  t.sources << Dir['Source/main.cpp']
  t.includes << ['Source']
  t.flags << ['--std=c++0x']
  t.libs << ['-lpthread', libs]
  t.pkgs << ['ruby']
  t.description = 'Build testable application'
end

multitask(default: Names[main])

C8.target :clean do
  ['lib', 'bin', RakeBuilder.outDir].each do |path|
    rm path
  end
end
