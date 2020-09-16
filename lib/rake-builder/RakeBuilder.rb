module RakeBuilder
  @@gpp = 'g++'
  @@ar = 'ar'

  def self.gpp
    @@gpp
  end

  def self.gpp= value
    @@gpp = value
  end

  def self.ar
    @@ar
  end

  def self.ar= value
    @@ar = value
  end

  module Desc
    def self.extended cls
      cls.instance_eval {
        @description = nil
      }
    end

    attr_accessor :description
    alias_method :desc=, :description=
  end

  module Track
    def self.extended cls
      cls.instance_eval {
        @track = nil
      }
    end

    def cl_ rebuild: [:change, :missing]
      if @track.kind_of? Symbol
        case @track
        when :requirements
          @cl_ ||= RakeBuilder::ComponentList.new(
            name: to_cl(@name),
            sources: Names[@requirements],
            rebuild: rebuild)
        when :sources
          @cl_ ||= RakeBuilder::ComponentList.new(
            name: to_cl(@name),
            sources: @sources,
            rebuild: rebuild)
        else
          raise UnknownOption.new(:track, @track)
        end
      elsif @track
        @cl_ ||= RakeBuilder::ComponentList.new(
          name: to_cl(@name),
          sources: Names[@track],
          rebuild: rebuild)
      end
    end

    attr_accessor :track
  end
end
