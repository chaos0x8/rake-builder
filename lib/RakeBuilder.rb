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

class Pkg
    def initialize name
        @name = name
    end

    def self.[] *args
        args.collect { |a| Pkg.new(a) }
    end

    def flags
        @flags ||= Shellwords.split(`pkg-config --cflags #{@name}`.chomp)
    end

    def libs
        @libs ||= Shellwords.split(`pkg-config --libs #{@name}`.chomp)
    end
end

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

    def unique taskName, &block
      unless @@definedTasks.include?(taskName)
        @@definedTasks.push(taskName)

        if block
          case block.arity
          when 0
            block.call
          when 1
            dirs = [ File.dirname(taskName) ].reject { |x| x== '.' }.each { | dir|
              unique(dir) {
                directory(dir)
              }
            }
            block.call(dirs)
          else
            raise 'Invalid block passed! Too many arguments!'
          end
        end
      end
    end

private
    def _files
      @files.flatten.collect { |x|
        if x.kind_of?(Generated)
          x.name
        else
          x
        end
      }
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

private
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

module RakeBuilder
  class Names
    def self.[](*args)
      args.collect { |a|
        if a.kind_of? Array
          Names[*a]
        elsif a.kind_of? GitSubmodule
          a.libs
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

class Library < Target
  attr_reader :targetDependencies

  def initialize(**opts, &block)
    super

    createRakeSourceTargets
    createRakeLibraryTarget
  end

private
  def createRakeLibraryTarget
    unique(@name) { |dir|
      @targetDependencies = [ dir, _files, to_obj(_sources), _dependencies ].flatten

      desc @description if @description
      file(@name => @targetDependencies) {
        sh "ar vsr #{@name} #{to_obj(_sources).join(' ')}"
      }
    }
  end
end

class SharedLibrary < Target
  attr_reader :targetDependencies

  def initialize(**opts, &block)
    super

    createRakeSourceTargets(:extraFlags => [ '-fPIC' ])
    createRakeSharedLibraryTarget
  end

private
  def createRakeSharedLibraryTarget
    unique(@name) { |dir|
      @targetDependencies = [ dir, _files, to_obj(_sources), _dependencies ].flatten

      desc @description if @description
      file(@name => @targetDependencies) {
        sh "g++ #{_flags} -shared #{to_obj(_sources).join(' ')} -o #{@name}".squeeze(' ')
      }
    }
  end
end


class Executable < Target
  attr_reader :targetDependencies

  def initialize(**opts, &block)
    super

    createRakeSourceTargets
    createRakeExecutableTarget
  end

private
  def createRakeExecutableTarget
    unique(@name) { |dir|
      @targetDependencies = [ dir, _files, to_obj(_sources), _dependencies ].flatten

      desc @description if @description
      file(@name => @targetDependencies) {
        sh "g++ #{_flags} #{to_obj(_sources).join(' ')} -o #{@name} #{_libs}".squeeze(' ')
      }
    }
  end
end

class Generated < Target
  attr_reader :targetDependencies
  attr_accessor :code

  def initialize(code: nil, **opts, &block)
    @code = code

    super(:mandatory => [:code], **opts, &block)

    unique(@name) { |dir|
      @targetDependencies = [ dir, _files, _dependencies ].flatten

      desc @description if @description
      file(@name => @targetDependencies) {
        @code.call
      }
    }
  end
end

class GitSubmodule < Target
  attr_accessor :name

  def initialize(**opts, &block)
    super(mandatory: [:libs], **opts, &block)

    unless File.exists? "#{@name}/.git"
      sh 'git submodule init'
      sh 'git submodule update'
    end

    Dir.chdir(@name) {
      sh "rake #{Shellwords.join(@libs)}"
    }
  end

  def libs
    @libs.collect { |x| "#{@name}/#{x}" }
  end

  def self.[] args = Hash.new
    args.collect { |subModule, libs|
      GitSubmodule.new { |mod|
        mod.name = subModule
        mod.libs = libs
      }
    }
  end
end

