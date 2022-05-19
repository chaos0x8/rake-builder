require_relative 'Target'
require_relative '../ComponentList'

class Library < RakeBuilder::Target
  def initialize(*args, **opts)
    warn "#{self.class} is deprecated, use C8.project.library instead"
    super(*args, **opts)

    required(:name)

    dir = Names[Directory.new(@name)]
    cl = cl_

    if @sources.empty?
      warn "There is no sources for: #{@name}"
    else
      desc @description if @description
      file(@name => Names[dir, @requirements, @sources, cl]) do
        FileUtils.rm @name, verbose: true if File.exist?(@name)
        C8.sh RakeBuilder.ar, 'vsr', @name, *Build[@sources],
              verbose: RakeBuilder.verbose, silent: RakeBuilder.silent,
              nonVerboseMessage: "#{RakeBuilder.ar} #{@name}"
      end
    end
  end

  def _names_
    if @sources.empty?
      []
    else
      [@name, @sources]
    end
  end

  def _build_
    if @sources.empty?
      []
    else
      [@name]
    end
  end
end
