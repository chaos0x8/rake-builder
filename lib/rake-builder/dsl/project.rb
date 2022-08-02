require_relative '../c8/tasks'

module RakeBuilder
  module DSL
    class Project
      include Rake::DSL
      include DSL::Base

      def_attr :flags, Utility::Flags
      def_attr :link_flags, Utility::Flags
      def_pkg_config
      def_link on_tail: true

      def initialize
        @libraries = []
        @executables = []
        @generated_files = []
        @externals = []
        @headers = []
        @configures = []
        @generate_target_name = builder.reserve_target_name

        yield(self) if block_given?
      end

      def library(*args, &block)
        project_block = proc do |t|
          t.flags << flags

          block.call t if block

          unless @generated_files.empty?
            t.depend @generate_target_name
            t.exclude_from_clean @generate_target_name
          end

          @configures.each do |conf|
            t.depend conf.name
            t.exclude_from_clean conf.name
          end
        end

        method(:library).super_method.call(*args, &project_block).tap do |lib|
          @libraries << lib
        end
      end

      def executable(*args, &block)
        project_block = proc do |t|
          t.flags << flags
          t.link_flags << link_flags

          block.call t if block

          (@libraries + @externals).each do |lib|
            t.link lib
          end

          unless @generated_files.empty?
            t.depend @generate_target_name
            t.exclude_from_clean @generate_target_name
          end

          @configures.each do |conf|
            t.depend conf.name
            t.exclude_from_clean conf.name
          end
        end

        method(:executable).super_method.call(*args, &project_block).tap do |exe|
          @executables << exe
        end
      end

      def generated_file(*args, &block)
        method(:generated_file).super_method.call(*args, &block).tap do |file|
          @generated_files << file

          C8.multiphony @generate_target_name => file.path.to_s

          exclude_from_clean @generate_target_name
        end
      end

      def external(*args, &block)
        method(:external).super_method.call(*args, &block).tap do |ext|
          @externals << ext
        end
      end

      def header(*args, &block)
        project_block = proc do |t|
          t.flags << flags

          block.call t if block
        end

        method(:header).super_method.call(*args, &project_block).tap do |header|
          @headers << header
        end
      end

      def configure(*args, &block)
        method(:configure).super_method.call(*args, &block).tap do |conf|
          @configures << conf
          exclude_from_clean conf.name
        end
      end

      def requirements(*filters)
        Utility::StringContainer.new.tap do |c|
          if filters.empty?
            (@libraries + @executables).each do |target|
              c << target.requirements
              c << target.path
            end
          else
            (@libraries + @executables).select do |target|
              filters.include?(target.path.to_s)
            end.each do |target|
              c << target.requirements
              c << target.path
            end
          end

          unless @generated_files.empty?
            c << @generated_files
            c.delete(@generate_target_name)
          end

          @headers.each do |header|
            c << header.requirements
          end

          @configures.each do |conf|
            c << conf.name
          end
        end
      end

      def_clean :requirements
    end

    def project(*args, &block)
      Project.new(*args, &block)
    end
  end
end
