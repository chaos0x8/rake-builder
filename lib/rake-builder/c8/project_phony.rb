require_relative 'project_dsl'

module C8
  class Project
    class Phony
      include Rake::DSL
      include Project::DSL
      include C8::Install

      attr_reader :name

      def self.command(name, &block)
        define_method(name) do |*args|
          instance_variable_set(:@commands, []) unless instance_variable_defined?(:@commands)
          instance_variable_get(:@commands).push(proc do
                                                   method(:"do_#{name}").call(*args, &block)
                                                 end)
        end

        define_method(:"do_#{name}") do |*args|
          instance_exec(*args.flatten, &block)
        end
      end

      %i[apt_install apt_remove gem_install gem_uninstall].each do |name|
        command name do |*pkgs|
          method(name).super_method.call(*pkgs)
        end
      end

      command :rm do |*paths|
        paths.each do |path|
          path = C8::Utility.to_pathname(path)

          if path.directory?
            FileUtils.rm_rf path, verbose: true
          elsif path.exist?
            FileUtils.rm path, verbose: true
          end
        end
      end

      command :mkdir do |path|
        path = C8::Utility.to_pathname(path)

        FileUtils.mkdir path, verbose: true unless path.directory?
      end

      command :cp do |src, dst|
        src = C8::Utility.to_pathname(src)
        dst = C8::Utility.to_pathname(dst)

        do_mkdir dst.dirname

        if src.directory?
          do_mkdir dst

          src.children.each do |child|
            do_cp child, dst.join(child.basename)
          end
        else
          unless dst.exist? && src.mtime == dst.mtime
            FileUtils.cp src, dst, verbose: true
            FileUtils.touch dst, mtime: src.mtime
          end
        end
      end

      command :sh do |*args|
        C8.sh(*args)
      end

      project_attr_writer :description

      def initialize(name, **opts, &block)
        @name = name

        initialize_project_attrs(**opts)

        instance_exec(self, &block)

        desc @description if @description
        C8.phony name do
          instance_variable_get(:@commands)&.each do |cmd|
            instance_exec(&cmd)
          end
        end
      end

      def make_rule(_project)
        name.to_s
      end
    end
  end
end
