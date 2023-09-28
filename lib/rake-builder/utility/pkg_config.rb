require_relative '../error/pkg_config_failure'

require 'shellwords'

module RakeBuilder
  module Utility
    class PkgConfig
      def initialize(*pkgs)
        @pkgs = pkgs
        @flags = nil
        @flags_link = nil
      end

      def flags
        @flags ||= capture_ '--cflags'
      end

      def flags_link
        @flags_link ||= capture_ '--libs'
      end

      private

      def capture_(option)
        out, st = Open3.capture2e('pkg-config', option, *@pkgs)
        raise Error::PkgConfigFailure, out.chomp if st.exitstatus != 0

        Shellwords.split(out)
      end
    end
  end
end
