require 'rake'
require 'pathname'

require_relative 'Install'

module C8
  class Target
    include Rake::DSL
    include C8::Install

    def initialize(name, type: :task, &block)
      @mkdir = []
      @dependencies = []
      @rm = []
      @apt_install = []
      @gem_install = []
      @desc = nil

      instance_eval(&block)

      method(:desc).super_method.call @desc if @desc
      C8.send(type, name => @dependencies.collect(&:to_s)) do
        do_rm
        do_apt_install
        do_gem_install
      end
    end

    def desc(val)
      @desc = val
    end

    def mkdir(path)
      path = to_pathname(path)

      directory path.to_s unless @mkdir.include?(path)

      @dependencies << path
    end

    def cp(src, dst)
      src = to_pathname(src)
      dst = to_pathname(dst)

      mkdir dst.dirname

      if src.directory?
        mkdir dst

        src.children.each do |child|
          cp child, dst.join(child.basename)
        end
      else
        file dst.to_s => [src.to_s, dst.dirname.to_s] do |_t|
          FileUtils.cp src, dst, verbose: true
        end
      end

      @dependencies << dst
    end

    def rm(path)
      @rm << to_pathname(path)
    end

    def apt_install(pkg)
      @apt_install << pkg
    end

    def gem_install(pkg)
      @gem_install << pkg
    end

    private

    def do_rm
      @rm.each do |path|
        if path.directory?
          FileUtils.rm_rf path, verbose: true
        elsif path.exist?
          FileUtils.rm path, verbose: true
        end
      end
    end

    def do_apt_install
      method(:apt_install).super_method.call(*@apt_install)
    end

    def do_gem_install
      method(:gem_install).super_method.call(*@gem_install)
    end

    def to_pathname(o)
      o.is_a?(Pathname) ? o : Pathname.new(o)
    end
  end

  def self.target(*args, **opts, &block)
    Target.new(*args, **opts, &block)
  end
end
