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
    class MissingBlock < RuntimeError
        def initialize
            super('Missing block')
        end
    end

    class MissingAttribute < RuntimeError
        def initialize attribute
            super("Missing attribute '#{attribute}'")
        end
    end

    module Transform
        def to_obj name
            method = 'to_obj_' + name.class.to_s
            send(method.to_sym, name)
        end

        def to_mf name
            'obj/' + change_ext(name, '.mf')
        end

    private
        def to_obj_String name
            'obj/' + change_ext(name, '.o')
        end

        def to_obj_Array name
            name.collect { |n|
                to_obj_String(n)
            }
        end

        def change_ext name, ext
            name.sub(/\.\w+$/, ext)
        end
    end

    module Utility
        def readDependencies depName
            result = Array.new

            File.open(depName, 'r') { |f|
                content = Shellwords.split(f.read.gsub("\\\n", ''))
                result = content.reject { |x|
                    x.match(/#{Regexp.quote('.o:')}$/)
                }
            } if File.exists?(depName)

            result
        end

        def onlyBasename filename
            tmp = File.basename(filename)
            tmp[0..tmp.size - 1 - File.extname(filename).size]
        end
    end

    class Names
        def self.[] *args
            args.collect { |a|
                if a.kind_of? Array
                    Names[*a]
                elsif a.kind_of? GitSubmodule
                    a.libs.collect { |l| "#{a.name}/#{l}" }
                elsif a.kind_of? Target
                    a.name
                elsif a.kind_of? Symbol
                    a
                else
                    a.to_s
                end
            }.flatten
        end
    end
end

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

    def initialize opts = Hash.new, &block
        @files = Array.new
        @sources = Array.new
        @flags = Array.new
        @includes = Array.new
        @libs = Array.new

        raise RakeBuilder::MissingBlock.new unless block

        block.call self

        [ :name, *(opts[:mandatory] || []) ].each { |mandatory|
            raise RakeBuilder::MissingAttribute.new(mandatory.to_s) unless send(mandatory)
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
                    dir = File.dirname(taskName)
                    unless @@definedTasks.include?(dir)
                        @@definedTasks.push(dir)
                        directory(dir)
                    end
                    block.call(dir)
                else
                    raise 'Invalid block passed! Too many arguments!'
                end
            end
        end
    end

private
    def dispatch obj, prefix
        if obj.kind_of? Rake::FileList
            dispatch(obj.to_a, prefix)
        elsif obj.kind_of? Array
            obj.collect { |item| dispatch(item, prefix) }.
                reject { |x| x.nil? or x.empty? }.flatten
        else
            private_methods.grep(/_#{Regexp.quote(prefix)}_\w+/).each { |symbol|
                clas = symbol.to_s.match(/_#{Regexp.quote(prefix)}_(\w+)/)[1]
                if obj.kind_of? Object.const_get(clas)
                    return send(symbol, obj)
                end
            }

            begin
                send("_#{prefix}Other".to_sym, obj)
            rescue NoMethodError
                nil
            end
        end
    end

    def _files
        dispatch(@files, 'files')
    end

    def _filesOther(obj) obj; end
    def _files_Generated(x) x.name; end

    def _sources
        dispatch(@sources, 'sources')
    end

    def _sourcesOther(obj) obj; end

    def _includes
        dispatch(@includes, 'includes').join(' ')
    end

    def _includesOther(obj) "-I#{Shellwords.escape(obj)}"; end
    def _includes_Array(x) x.collect { |xx| _includesDispatch(xx) }.reject { |xx| xx.nil? or xx.empty? }.join(' '); end

    def _flags
        (@flags + dispatch(@libs, 'flags')).join(' ')
    end

    def _flags_Pkg(x) x.flags.join(' '); end

    def _libs
        dispatch(@libs, 'libs').join(' ')
    end

    def _libsOther(obj) obj; end
    def _libs_Pkg(x) x.libs.join(' '); end
    def _libs_GitSubmodule(x) x.libs.join(' '); end
    def _libs_Target(x) x.name; end

    def _dependencies
        dispatch(@libs, 'dependencies')
    end

    def _dependencies_Target(x) x.name; end

private
    def createRakeSourceTargets opts = Hash.new
        opts[:extraFlags] ||= Array.new

        _sources.each { |source|
            dependencies = readDependencies(to_mf(source))

            dependencies.each { |d|
                unique(d) {
                    file(d) {
                        Rake::Task[to_mf(source)].execute
                    }
                } unless File.exists?(d)
            }

            unique(to_mf(source)) { |dir|
                file(to_mf(source) => [dir, source] + dependencies) {
                    sh "g++ #{_flags} #{opts[:extraFlags].join(' ')} #{_includes} -c #{source} -M -MM -MF #{to_mf(source)}".squeeze(' ')
                }
            }

            unique(to_obj(source)) { |dir|
                file(to_obj(source) => [dir, to_mf(source)]) {
                    sh "g++ #{_flags} #{opts[:extraFlags].join(' ')} #{_includes} -c #{source} -o #{to_obj(source)}".squeeze(' ')
                }
            }
        }
    end
end

class Library < Target
    def initialize &block
        super

        createRakeSourceTargets
        createRakeLibraryTarget
    end

private
    def createRakeLibraryTarget
        unique(@name) { |dir|
            desc @description if @description
            file(@name => [dir] + _files + to_obj(_sources) + _dependencies) {
                sh "ar vsr #{@name} #{to_obj(_sources).join(' ')}"
            }
        }
    end
end

class SharedLibrary < Target
    def initialize &block
        super

        createRakeSourceTargets(:extraFlags => [ '-fPIC' ])
        createRakeSharedLibraryTarget
    end

private
    def createRakeSharedLibraryTarget
        unique(@name) { |dir|
            desc @description if @description
            file(@name => [dir] + _files + to_obj(_sources) + _dependencies) {
                sh "g++ #{_flags} -shared #{to_obj(_sources).join(' ')} -o #{@name}".squeeze(' ')
            }
        }
    end
end

class Executable < Target
    def initialize &block
        super

        createRakeSourceTargets
        createRakeExecutableTarget
    end

private
    def createRakeExecutableTarget
        unique(@name) { |dir|
            desc @description if @description
            file(@name => [dir] + _files + to_obj(_sources) + _dependencies) {
                sh "g++ #{_flags} #{to_obj(_sources).join(' ')} -o #{@name} #{_libs}".squeeze(' ')
            }
        }
    end
end

class Generated < Target
    attr_accessor :code

    def initialize &block
        super(:mandatory => [ :code ], &block)

        unique(@name) { |dir|
            desc @description if @description
            file(@name => [dir] + _files + _dependencies) {
                @code.call
            }
        }
    end
end

class GitSubmodule < Target
    attr_accessor :name

    def initialize &block
        super(:mandatory => [:libs], &block)

        unless File.exists? "#{@name}/.git"
            sh 'git submodule init'
            sh 'git submodule update'
        end

        Dir.chdir(@name) {
            begin
                pid = Process.spawn('rake', *@libs)
                Process.wait(pid)
            rescue Interrupt
                Process.kill('TERM', pid)
                Process.wait(pid)
                raise
            end
        }
    end

    def libs
        @libs.collect { |x| "#{@name}/#{x}" }
    end

    def self.[] args = Hash.new
        result = Array.new
        args.each { |subModule, libs|
            result << GitSubmodule.new { |mod|
                mod.name = subModule
                mod.libs = libs
            }
        }
        result
    end
end

