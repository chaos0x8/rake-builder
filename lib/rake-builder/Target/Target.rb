module RakeBuilder
  class Target
    include RakeBuilder::Utility
    include RakeBuilder::Transform
    include Rake::DSL

    attr_accessor :name, :description
    attr_reader :flags, :includes, :sources, :libs, :pkgs, :requirements

    def initialize(name: nil, sources: [], includes: [], flags: [], libs: [], pkgs: [], requirements: [], description: nil)
      @name = name
      @flags = RakeBuilder::Flags.new(flags)
      @libs = RakeBuilder::Libs.new(libs)
      @pkgs = RakeBuilder::Pkgs.new(pkgs, flags: @flags, libs: @libs)
      @includes = RakeBuilder::Includes.new(includes)
      @requirements = RakeBuilder::Requirements.new(requirements)
      @sources = RakeBuilder::Sources.new(sources, flags: @flags, includes: @includes, requirements: @requirements)
      @description = description

      yield(self) if block_given?

      required(:name, :sources)
    end

    def _names_
      [ @name, @sources ]
    end
  end
end
