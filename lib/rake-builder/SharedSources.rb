require_relative 'Utility'

class SharedSources
  class Slice
    def initialize ss, *tags
      @sharedSources = ss
      @tags = tags
    end

    def >> target
      @tags.each { |field|
        target.send(field) << @sharedSources.send(field)
      }

      nil
    end
  end

  include RakeBuilder::Utility

  attr_reader :sources, :libs, :flags, :includes, :pkgs, :requirements

  def initialize sources: [], libs: [], flags: [], includes: [], pkgs: [], requirements: []
    @flags = RakeBuilder::Flags.new(flags)
    @libs = RakeBuilder::Libs.new(libs)
    @pkgs = RakeBuilder::Pkgs.new(pkgs, flags: @flags, libs: @libs)
    @requirements = RakeBuilder::Requirements.new(requirements)
    @includes = RakeBuilder::Includes.new(includes)

    @sources = RakeBuilder::Sources.new(
      sources,
      flags: @flags,
      includes: @includes,
      requirements: @requirements)

    yield(self) if block_given?

    required(:sources)
  end

  def slice *tags
    Slice.new(self, *tags)
  end

  def >> target
    Slice.new(self, :sources, :libs, :flags, :includes, :pkgs, :requirements) >> target
  end
end
