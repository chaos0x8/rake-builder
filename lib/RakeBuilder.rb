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

module RakeBuilder
  module Utility
    include Rake::DSL

    def readMf(mf)
      if File.exist?(mf)
        File.open(mf, 'r') { |f|
          dependencies = Shellwords.split(f.read.gsub("\\\n", '')).reject { |x|
            x.match(/#{Regexp.quote('.o:')}$/)
          }

          if dependencies.any? { |fn| not File.exist?(fn) }
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
        raise RakeBuilder::MissingAttribute.new(sym.to_s) if value.nil? or (value.respond_to?(:empty?) and value.empty?)
      }
    end

    def _build_join_ obj
      Shellwords.join(Build[obj])
    end
  end

  class MissingAttribute < RuntimeError
    def initialize attribute
      super("Missing attribute '#{attribute}'")
    end
  end

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

  class Names
    def self.[](*args)
      args.collect { |a|
        if a.kind_of? Array
          Names[*a]
        elsif a.respond_to? :_names_
          Names[a._names_]
        else
          a.to_s
        end
      }.flatten
    end
  end

  class Build
    def self.[](*args)
      args.collect { |a|
        if a.kind_of? Array
          Build[*a]
        elsif a.respond_to? :_build_
          Build[a._build_]
        elsif a.respond_to? :_names_
          Names[a._names_]
        else
          a.to_s
        end
      }.flatten
    end
  end

  class Flags
    def initialize flags
      @value = Array.new
      @std = Array.new

      self << flags
    end

    def << flags
      @value << flags
      @value = @value.flatten.uniq

      @std << @value.select { |x| x.match('-std=') }
      @std.flatten.uniq

      @value = @value.reject { |x| x.match('-std=') }

      self
    end

    def _names_
      raise TypeError.new('This type should not be used by Names')
    end

    def _build_
      @value + _std_
    end

  private
    def _std_
      if maxStd = @std.flatten.collect { |x| x.match(/-std=(.*)$/)[1] }.max
        [ "--std=#{maxStd}" ]
      else
        Array.new
      end
    end
  end

  module ExOnNames
    def _names_
      raise TypeError.new('This type should not be used by Names')
    end
  end

  module ExOnBuild
    def _build_
      raise TypeError.new('This type should not be used by Build')
    end
  end

  class ArrayWrapper
    include ExOnNames
    include ExOnBuild

    def initialize item
      @value = Array.new
      self << item
    end

    def << item
      @value << item
      @value = @value.flatten.uniq
    end
  end

  class Includes < ArrayWrapper
    def _build_
      @value.collect { |inc| "-I#{inc}" }
    end
  end

  class Sources
    def initialize(sources, flags:, includes:, requirements:)
      @value = Array.new
      @flags = flags
      @includes = includes
      @requirements = requirements

      self << sources
    end

    def << sources
      [ sources ].flatten.each { |src|
        if src.kind_of? SourceFile
          @value << src
        else
          @value << SourceFile.new(name: src, flags: @flags, includes: @includes, requirements: @requirements)
        end
      }
    end

    def empty?
      @value.empty?
    end

    def _names_
      @value
    end
  end

  class Libs < ArrayWrapper
    def _names_
      @value.select { |x| x.respond_to?(:_names_) }
    end

    def _build_
      @value
    end
  end

  class Pkgs
    include ExOnNames
    include ExOnBuild

    def initialize(pkgs, flags:, libs:)
      @flags = flags
      @libs = libs

      self << pkgs
    end

    def << pkgs
      [ pkgs ].flatten.reject { |pkg| pkg.nil? }.each { |pkg|
        @flags << Shellwords.split(`pkg-config --cflags #{Shellwords.escape(pkg)}`.chomp)
        @libs << Shellwords.split(`pkg-config --libs #{Shellwords.escape(pkg)}`.chomp)
      }
    end
  end

  class Requirements < ArrayWrapper
    def _names_
      @value
    end
  end
end

module RakeBuilder
  module Detail
    class Target
      include RakeBuilder::Utility
      include RakeBuilder::Transform
      include Rake::DSL

      attr_accessor :name, :description
      attr_reader :flags, :includes, :sources, :libs, :pkgs, :requirements

      def initialize(name: nil, sources: [], includes: [], flags: [], libs: [], pkgs: [], requirements: [], description: nil)
        @name = name
        @flags = RakeBuilder::Flags.new(flags)
        @libs = RakeBuilder::Libs.new(libs)
        @pkgs = RakeBuilder::Pkgs.new(pkgs, flags: @flags, libs: @libs)
        @includes = RakeBuilder::Includes.new(includes)
        @requirements = RakeBuilder::Requirements.new(requirements)
        @sources = RakeBuilder::Sources.new(sources, flags: @flags, includes: @includes, requirements: @requirements)
        @description = description

        yield(self) if block_given?

        required(:name, :sources)
      end

      def _names_
        [ @name, @sources ]
      end
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

  def _names_
    (@name == '.') ? [] : @name
  end
end

class SourceFile
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :flags, :includes, :description

  def initialize(name: nil, flags: [], includes: [], requirements: [], description: nil)
    @name = name
    @flags = flags
    @includes = includes
    @description = description
    @requirements = RakeBuilder::Names[requirements]

    yield(self) if block_given?

    required(:name)

    dir = RakeBuilder::Names[Directory.new(name: to_obj(@name))]
    file(to_mf(@name) => [ dir, @requirements, readMf(to_mf(@name)), @name ].flatten) {
      sh "g++ #{_build_join_(@flags)} #{_build_join_(@includes)} -c #{@name} -M -MM -MF #{to_mf(@name)}".squeeze(' ')
    }

    desc @description if @description
    file(to_obj(@name) => [ dir, @requirements, to_mf(@name), @name ].flatten) {
      sh "g++ #{_build_join_(@flags)} #{_build_join_(@includes)} -c #{@name} -o #{to_obj(@name)}".squeeze(' ')
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

    file("#{@name}/.git") {
      sh 'git submodule init'
      sh 'git submodule update'
    }

    @libs.each { |library|
      file("#{@name}/#{library}" => ["#{@name}/.git"]) {
        sh "cd #{@name} && rake #{Shellwords.escape(library)}"
      }

      Rake::Task["#{@name}/#{library}"].invoke
    }
  end

  def _names_
    @libs.collect { |lib|
      "#{@name}/#{lib}"
    }
  end
end

class Executable < RakeBuilder::Detail::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = RakeBuilder::Names[Directory.new(name: @name)]
    file(@name => RakeBuilder::Names[dir, @requirements, @sources, @libs]) {
      sh "g++ #{_build_join_(@flags)} #{_build_join_(@sources)} -o #{@name} #{_build_join_(@libs)}".squeeze(' ')
    }
  end

  def _names_
    [ @name, @sources, @libs ]
  end
end

class Library < RakeBuilder::Detail::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = RakeBuilder::Names[Directory.new(name: @name)]
    file(@name => RakeBuilder::Names[dir, @requirements, @sources]) {
      sh "ar vsr #{@name} #{_build_join_(@sources)}"
    }
  end

  def _build_
    RakeBuilder::Build[@name]
  end
end

