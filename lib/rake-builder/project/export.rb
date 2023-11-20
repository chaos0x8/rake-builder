require_relative 'attributes'
require_relative '../utility/container_flag_compile'
require_relative '../utility/container_flag_link'

module RakeBuilder
  class Project
    class Export
      include Attributes

      attr_dependencies

      attr_container :flags, Utility::ContainerFlagCompile
      attr_container :flags_link, Utility::ContainerFlagLink

      attr_reader :project

      def initialize(project_)
        @project_ = project_

        yield self if block_given?
      end

      def >>(other)
        %i[flags flags_link dependencies].each do |attribute|
          other.send(attribute) << send(attribute) if other.respond_to?(attribute)
        end
      end
    end

    def export(&block)
      Export.new(self, &block)
    end
  end
end
