#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2015, <https://github.com/chaos0x8>
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

require 'set'
require 'rake'

task :rebuild

task :modules do
    if File.exists? ".gitmodules" and Dir["*/.git"].empty?
        sh "git submodule init"
        sh "git submodule update"
    end
end

module Transform
    def obj cppName
        "obj/" + cppName.sub(/\.\w+$/, ".o")
    end

    def objs cppNames
        result = Set.new

        cppNames.flatten.each do |cppName|
            result.add(obj(cppName))
        end

        result.to_a
    end

    def cpp file
        file.sub(/\.o$/, ".cpp").sub(/^obj\//, "")
    end

    def dep cppName
        "obj/" + cppName.sub(/\.\w+$/, ".mf")
    end

    def getFileContent fileName
        content = nil

        f = File.open(fileName, "r")
        content = f.read
        f.close

        content
    end

    def readDependencies depName
        return Array.new unless File.exists?(depName)

        content = getFileContent(depName)
        content = content.sub(/^[\w\-]+\.o:/, "")
        content = content.gsub(/\\ /, "\\SPACE\\")
        content = content.gsub(/\\$/, "")
        content = content.split("\n")
        content.size.times do |i|
            content[i] = content[i].split(" ")
        end
        content = content.flatten
        content.each do |x|
            x.gsub!("\\SPACE\\", " ")
        end
        if content.index { |x| not File.exists?(x) }
            content.delete_if { |x| not File.exists?(x) }
            content.push :rebuild
        end
        content
    end
end

class Pkg
    def initialize package
        @package = package
    end

    def libs
        @libs ||= pkg_config "--libs"
        @libs
    end

    def includes
        @includes ||= pkg_config "--cflags"
        @includes
    end

    def pkg_config option
        result = Set.new
        `pkg-config #{@package} #{option}`.chomp.split(" ").each do |y|
            result.add y
        end
        result
    end
    private :pkg_config
end

class Target
    include Rake::DSL
    include Transform

    attr_accessor :name
    attr_accessor :files
    attr_accessor :flags
    attr_accessor :includes
    attr_accessor :libs
    attr_accessor :dependencies

    @@tasks = Set.new

    def initialize &block
        block.call self

        createFileRules
        createTargetRule
        @@tasks.add @name
    end

    def self.tasks patern
        result = Array.new
        @@tasks.each do |t|
            result.push t if t.match(patern)
        end
        result
    end

private
    def flags
        @flags ||= Array.new
        @extraFlags ||= Array.new
        (@flags + @extraFlags).uniq.join(" ")
    end

    def flagsOnly
        @flags ||= Array.new
        @flags.join(" ")
    end

    def includes
        result = Set.new

        @includes ||= Array.new
        @includes.each do |x|
            result.add "-I#{x}".strip
        end

        @libs ||= Array.new
        @libs.each do |x|
            result.add x.includes if defined? x.includes
            result.flatten!
        end

        result.to_a.join(" ")
    end

    def libs
        result = Set.new

        @libs ||= Array.new
        @libs.each do |x|
            if defined? x.libs
                result.add x.libs
            else
                result.add x.strip
            end
            result.flatten!
        end

        result.to_a.join(" ")
    end

    def dependencies
        @dependencies ||= Array.new
        @dependencies
    end

    def createFileRules
        @files.each do |cppName|
            objName = obj(cppName)
            depName = dep(cppName)
            objDirName = File.dirname(objName)

            directory objDirName

            file depName => [ cppName, objDirName ] + readDependencies(depName) do
                sh "g++ #{flags} #{includes} -M -MM -MF #{depName} -c #{cppName}"
            end

            Rake::Task[depName].invoke

            if cppName.match(/.*\.c$/)
                file objName => [ cppName, objDirName ] + readDependencies(depName) do
                    sh "gcc #{flags} #{includes} -c #{cppName} -o #{objName}"
                end
            else
                file objName => [ cppName, objDirName ] + readDependencies(depName) do
                    sh "g++ #{flags} #{includes} -c #{cppName} -o #{objName}"
                end
            end
        end
    end
end

class Application < Target
private
    def createTargetRule
        dirName = File.dirname(@name)
        directory dirName

        file @name => dependencies + [ dirName ] + objs(@files) do
            sh "g++ #{flags} #{objs(@files).join(" ")} -o #{@name} #{libs}"
        end
    end
end

class Library < Target
private
    def createTargetRule
        dirName = File.dirname(@name)
        directory dirName

        file @name => dependencies + [ dirName ] + objs(@files) do
            sh "ar vsr #{@name} #{objs(@files).join(" ")}"
        end
    end
end

class SharedLibrary < Target
    def initialize &block
        @extraFlags = [ "-fPIC" ]
        super
    end

private
    def createTargetRule
        dirName = File.dirname(@name)
        directory dirName

        file @name => dependencies + [ dirName ] + objs(@files) do
            sh "g++ -shared #{flagsOnly} #{objs(@files).join(" ")} -o #{name}"
        end
    end
end
