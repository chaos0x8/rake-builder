require 'rake'
require 'pathname'

require_relative 'Install'

module C8
  class Target
    include Rake::DSL
    include C8::Install

    @commands = []

    def self.command(name, aggregate: false, &block)
      define_method(name) do |*args, **opts|
        instance_variable_get(:"@#{name}") << [args, opts]
      end

      if aggregate
        define_method(:"do_#{name}") do
          args, opts = instance_variable_get(:"@#{name}").each_with_object([[], {}]) do |item, sum|
            sum[0] += item[0]
            sum[1].merge!(item[1])
          end

          instance_exec(*args, **opts, &block)
        end
      else
        define_method(:"do_#{name}") do
          instance_variable_get(:"@#{name}").each do |args, opts|
            instance_exec(*args, **opts, &block)
          end
        end
      end

      @commands << name
    end

    command :rm do |path|
      path = to_pathname(path)

      if path.directory?
        FileUtils.rm_rf path, verbose: true
      elsif path.exist?
        FileUtils.rm path, verbose: true
      end
    end

    command :apt_install, aggregate: true do |pkgs|
      method(:apt_install).super_method.call(*pkgs)
    end

    command :apt_remove, aggregate: true do |pkgs|
      method(:apt_remove).super_method.call(*pkgs)
    end

    command :gem_install, aggregate: true do |pkgs|
      method(:gem_install).super_method.call(*pkgs)
    end

    command :gem_uninstall, aggregate: true do |pkgs|
      method(:gem_uninstall).super_method.call(*pkgs)
    end

    def initialize(name, type: :task, &block)
      @mkdir = []
      @dependencies = []
      @desc = nil

      self.class.instance_variable_get(:@commands).each do |cmd|
        instance_variable_set(:"@#{cmd}", [])
      end

      instance_eval(&block)

      method(:desc).super_method.call @desc if @desc
      C8.send(type, name => @dependencies.collect(&:to_s)) do
        self.class.instance_variable_get(:@commands).each do |cmd|
          send(:"do_#{cmd}")
        end
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

    private

    def to_pathname(o)
      o.is_a?(Pathname) ? o : Pathname.new(o)
    end
  end

  def self.target(*args, **opts, &block)
    Target.new(*args, **opts, &block)
  end
end
