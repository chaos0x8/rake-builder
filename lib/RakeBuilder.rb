#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2016, <https://github.com/chaos0x8>
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

require 'shellwords'
require 'rake'

# -------------- V2

module RakeBuilder
  module Utility
    include Rake::DSL

    def readMf(mf)
      if File.exists?(mf)
        File.open(mf, 'r') { |f|
          dependencies = Shellwords.split(f.read.gsub("\\\n", '')).reject { |x|
            x.match(/#{Regexp.quote('.o:')}$/)
          }

          if dependencies.any? { |fn| not File.exists?(fn) }
            sh "rm #{Shellwords.escape(mf)}"
            Array.new
          else
            dependencies
          end
        }
      else
        Array.new
      end
    end

    def required *attributes
      attributes.each { |sym|
        value = send(sym)
        raise RakeBuilder::MissingAttribute.new(sym.to_s) if value.nil? or (value.kind_of?(Array) and value.empty?)
      }
    end
  end
end

module RakeBuilder
  class MissingAttribute < RuntimeError
    def initialize attribute
      super("Missing attribute '#{attribute}'")
    end
  end
end

module RakeBuilder
  module Transform
    def to_obj name
      chExt(name, '.o')
    end

    def to_mf name
      chExt(name, '.mf')
    end

  private
    def chExt(x, ext)
      if x.respond_to?(:collect)
        x.collect { |y| chExt(y, ext) }
      else
        '.obj/' + x.ext(ext)
      end
    end
  end
end

# -------------- V1

class Target
    include Rake::DSL
    include RakeBuilder::Transform
    include RakeBuilder::Utility

    attr_accessor :name, :files, :sources, :flags, :includes, :libs, :description

    @@definedTasks = Array.new

    def initialize(name: nil, files: [], sources: [], flags: [], includes: [], libs: [], mandatory: [], &block)
        @name = name
        @files = files
        @sources = sources
        @flags = flags
        @includes = includes
        @libs = libs

        block.call(self) if block

        [ :name, *mandatory ].collect { |sym| [ sym, send(sym) ] }.each { |sym, value|
          raise RakeBuilder::MissingAttribute.new(sym.to_s) if value.nil? or (value.kind_of?(Array) and value.empty?)
        }
    end

    def unique taskName
      raise SyntaxError.new('Needs block!') unless block_given?
      raise RuntimeError.new("Task #{taskName} is already defined!") if @@definedTasks.include?(taskName)

      @@definedTasks.push(taskName)

      dirs = [ File.dirname(taskName) ].reject { |x| x== '.' }.each { | dir|
        unique(dir) {
          directory(dir)
        } unless @@definedTasks.include?(dir)
      }
      yield(dirs)
    end

private
    def _files
      @files.flatten
    end

    def _sources
      @sources.flatten
    end

    def _includes
      @includes.flatten.collect { |x| "-I#{Shellwords.escape(x)}" }.join(' ')
    end

    def _flags
      pkgs = @libs.flatten.select { |x| x.kind_of?(Pkg) }
      pkgFlags = pkgs.collect { |x| x.flags }
      (@flags + pkgFlags).flatten.join(' ')
    end

    def _libs
      @libs.flatten.collect { |x|
        if x.kind_of?(Pkg) or x.kind_of?(GitSubmodule)
          x.libs
        elsif x.kind_of?(Target)
          x.name
        else
          x
        end
      }.flatten.join(' ')
    end

    def _dependencies
      RakeBuilder::Names[@libs.flatten.select { |x| x.kind_of?(Target) }]
    end

    def createRakeSourceTargets(extraFlags: [])
      _sources.each { |source|
        dependencies = readMf(to_mf(source))

        unique(to_mf(source)) { |dir|
          file(to_mf(source) => [dir, source, dependencies].flatten) {
            sh "g++ #{_flags} #{extraFlags.join(' ')} #{_includes} -c #{source} -M -MM -MF #{to_mf(source)}".squeeze(' ')
          }
        }

        unique(to_obj(source)) { |dir|
          file(to_obj(source) => [dir, to_mf(source)].flatten) {
            sh "g++ #{_flags} #{extraFlags.join(' ')} #{_includes} -c #{source} -o #{to_obj(source)}".squeeze(' ')
          }
        }
      }
    end
end

# -------------- V2

class Target
  def createRakeTarget
    unique(@name) { |dir|
      @targetDependencies = [ dir, _files, to_obj(_sources), _dependencies ].flatten

      desc @description if @description
      file(@name => @targetDependencies) {
        yield
      }
    }
  end
end

class Library < Target
  attr_reader :targetDependencies

  def initialize(**opts, &block)
    super

    createRakeSourceTargets
    createRakeTarget {
      sh "ar vsr #{@name} #{to_obj(_sources).join(' ')}"
    }
  end
end

class SharedLibrary < Target
  attr_reader :targetDependencies

  def initialize(**opts, &block)
    super

    createRakeSourceTargets(:extraFlags => [ '-fPIC' ])
    createRakeTarget {
      sh "g++ #{_flags} -shared #{to_obj(_sources).join(' ')} -o #{@name}".squeeze(' ')
    }
  end
end

# -------------- V3

module RakeBuilder
  class Names
    def self.[](*args)
      args.collect { |a|
        if a.kind_of? Array
          Names[*a]
        elsif a.respond_to? :_names_
          a._names_
        elsif a.kind_of? Target
          Enumerator.new { |e|
            e << a.name
            e << Names[*a.targetDependencies] if a.respond_to? :targetDependencies
          }.to_a
        elsif a.kind_of? Symbol
          a
        else
          a.to_s
        end
      }.flatten
    end
  end
end

class Directory
  include Rake::DSL

  attr_reader :name

  @@definedDirs = []

  def initialize(name:)
    @name = File.dirname(name)

    yield(self) if block_given?

    unless @@definedDirs.include?(@name) and @name != '.'
      directory(@name)
      @@definedDirs << @name
    end
  end

  alias_method :_names_, :name
end

class SourceFile
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :flags, :includes, :description
  attr_reader :dependencies

  def initialize(name: nil, flags: [], includes: [], description: nil)
    @name = name
    @flags = flags
    @includes = includes
    @description = description

    yield(self) if block_given?

    required(:name)

    dir = RakeBuilder::Names[Directory.new(name: to_obj(@name))]
    @dependencies = readMf(to_mf(@name))

    file(to_mf(@name) => [ dir, @dependencies, @name ].flatten) {
      sh "g++ #{_flags_} #{_includes_} -c #{@name} -M -MM -MF #{to_mf(@name)}".squeeze(' ')
    }

    desc @description if @description
    file(to_obj(@name) => [ dir, to_mf(@name), @name ].flatten) {
      sh "g++ #{_flags_} #{_includes_} -c #{@name} -o #{to_obj(@name)}".squeeze(' ')
    }
  end

  def _names_
    to_obj(@name)
  end
end

class GeneratedFile
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :code, :description

  def initialize(name: nil, code: nil, description: nil)
    @name = name
    @code = code
    @description = description

    yield(self) if block_given?

    required(:name, :code)

    dir = RakeBuilder::Names[Directory.new(name: @name)]

    desc @description if @description
    file(@name => dir) {
      @code.call(@name)
    }
  end

  alias_method :_names_, :name
end

class GitSubmodule
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :libs

  def initialize(name: nil, libs: [])
    @name = name
    @libs = libs

    yield(self) if block_given?

    required(:name, :libs)

    unless File.directory? "#{@name}/.git"
      sh 'git submodule init'
      sh 'git submodule update'
    end

    @libs.each { |library|
      file("#{@name}/#{library}" => []) {
        Dir.chdir(@name) {
          sh "rake #{Shellwords.escape(library)}"
        }
      }
    }
  end

  def _names_
    @libs.collect { |lib|
      "#{@name}/#{lib}"
    }
  end
end

class Pkg
  def initialize(name:)
    @name = name
  end

  def self.[] *args
    args.collect { |a| Pkg.new(name: a) }
  end

  def flags
    @flags ||= Shellwords.split(`pkg-config --cflags #{@name}`.chomp)
  end

  def libs
    @libs ||= Shellwords.split(`pkg-config --libs #{@name}`.chomp)
  end

  def _names_
    Array.new
  end
end

class Executable
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :sources, :includes, :flags, :libs, :description

  def initialize(name: nil, sources: [], includes: [], flags: [], libs: [], description: nil)
    @name = name
    @sources = sources
    @includes = includes
    @flags = flags
    @libs = libs
    @description = description

    yield(self) if block_given?

    required(:name, :sources)
  end

  def _names_
    [ @name, @sources ]
  end
end

#class Executable < Target
#  attr_reader :targetDependencies

#  def initialize(**opts, &block)
#    super

#    createRakeSourceTargets
#    createRakeTarget {
#      sh "g++ #{_flags} #{to_obj(_sources).join(' ')} -o #{@name} #{_libs}".squeeze(' ')
#    }
#  end
#end
