require_relative 'Target'

class SourceFile < RakeBuilder::Target
  attr_accessor :name
  attr_reader :flags, :includes, :requirements

  def initialize(name: nil, flags: [], includes: [], requirements: [], description: nil)
    extend RakeBuilder::Desc

    @name = name
    @flags = flags
    @includes = includes
    @description = description
    @requirements = RakeBuilder::Requirements.new(requirements)

    yield(self) if block_given?

    required(:name)

    dir = Names[Directory.new(to_obj(@name))]
    file(to_mf(@name) => Names[dir, @requirements, readMf(to_mf(@name)), @name]) {
      C8.sh RakeBuilder::gpp, *Build[@flags], *Build[@includes],
            '-c', @name, '-M', '-MM', '-MF', to_mf(@name), verbose: true
    }

    desc @description if @description
    file(to_obj(@name) => Names[dir, @requirements, to_mf(@name), @name]) {
      C8.sh RakeBuilder::gpp, *Build[@flags], *Build[@includes],
            '-c', @name, '-o', to_obj(@name), verbose: true
    }
  end

  def _names_
    to_obj(@name)
  end
end
