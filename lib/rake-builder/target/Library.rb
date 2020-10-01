require_relative 'Target'
require_relative '../ComponentList'

class Library < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    required(:name, :sources)

    dir = Names[Directory.new(@name)]
    cl = cl_

    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, cl]) {
      FileUtils.rm @name, verbose: true if File.exist?(@name) and not File.directory?(@name)
      C8.sh RakeBuilder::ar, 'vsr', @name, *Build[@sources], verbose: true
    }
  end

  def _build_
    Build[@name]
  end
end

