require_relative 'Target'
require_relative '../ComponentList'

class Executable < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    required(:name, :sources)

    dir = Names[Directory.new(@name)]
    cl = cl_

    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, @libs, cl]) {
      C8.sh RakeBuilder::gpp, *Build[@flags], *Build[@sources],
            '-o', @name, *Build[@libs], verbose: true
    }
  end

  def _names_
    [ @name, @sources, @libs ]
  end
end

