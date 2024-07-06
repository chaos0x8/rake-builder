require 'etc'

module RakeBuilder
  module PlatformHelper
    module Detail
      def self.platform
        case Etc.uname[:sysname]
        when 'Windows_NT'
          :windows
        when 'Linux'
          :linux
        end
      end

      def self.for_platform(arg, platform:, &block)
        raise ArgumentError, 'Expected arg or block, but got none.' if block.nil? && arg.nil?
        raise ArgumentError, 'Expected arg or block, but got both of them.' if block && arg

        return unless Detail.platform == platform

        if block
          block.call
        else
          arg
        end
      end
    end

    def for_platform(linux:, windows: nil)
      case Detail.platform
      when :windows
        windows
      when :linux
        linux
      end
    end

    def for_windows(arg = nil, &block)
      Detail.for_platform(arg, platform: :windows, &block)
    end

    def for_linux(arg = nil, &block)
      Detail.for_platform(arg, platform: :linux, &block)
    end
  end
end
