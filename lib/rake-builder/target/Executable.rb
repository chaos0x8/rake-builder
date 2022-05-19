require_relative 'Target'
require_relative '../ComponentList'

class Executable < RakeBuilder::Target
  def initialize(*args, **opts)
    warn "#{self.class} is deprecated, use C8.project.executable instead"
    super(*args, **opts)

    required(:name)

    dir = Names[Directory.new(@name)]
    cl = cl_

    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, @libs, cl]) do
      C8.sh RakeBuilder.gpp, *Build[@flags], *Build[@sources],
            '-o', @name, *Build[@libs],
            verbose: RakeBuilder.verbose, silent: RakeBuilder.silent,
            nonVerboseMessage: "#{RakeBuilder.gpp} #{@name}"
    end
  end

  def _names_
    [@name, @sources, @libs]
  end
end
