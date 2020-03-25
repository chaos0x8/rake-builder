require_relative 'ArrayWrapper'

module RakeBuilder
  class Flags < ArrayWrapper
    def _build_
      build = Build[@value]

      flags = []
      stdFlags = []

      build.each { |flag|
        if flag.match(/^-*std=/)
          stdFlags << flag
        else
          flags << flag
        end
      }

      flags + _std(stdFlags)
    end

  private
    def _std stdFlags
      if maxStd = stdFlags.flatten.collect { |x| x.match(/-std=(.*)$/)[1] }.max
        [ "--std=#{maxStd}" ]
      else
        []
      end
    end
  end
end
