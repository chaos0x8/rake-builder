require_relative 'ArrayWrapper'

module RakeBuilder
  class Track < ArrayWrapper
    module Ext
      def self.extended cls
        cls.instance_eval {
          @track_ = Track.new(nil)
        }
      end

      def tracked
        Names[@track_]
      end

      def track item
        if item.kind_of? Symbol
          case item
          when :requirements
            @track_ << Names[@requirements]
          when :sources
            @track_ << Names[@sources]
          else
            rause UnknownOption.new(:track, item)
          end
        elsif item
          @track_ << Names[item]
        end
      end

      def cl_ rebuild: [:change, :missing]
        @cl_ ||= RakeBuilder::ComponentList.new(
          name: to_cl(@name),
          sources: tracked,
          rebuild: rebuild)
      end
    end

    def _names_
      @value
    end
  end
end
