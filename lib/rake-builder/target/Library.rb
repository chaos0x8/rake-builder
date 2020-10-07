require_relative 'Target'
require_relative '../ComponentList'

class Library < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    required(:name)

    dir = Names[Directory.new(@name)]
    cl = cl_

    if @sources.empty?
      $stderr.puts "There is no sources for: #{@name}"
    else
      desc @description if @description
      file(@name => Names[dir, @requirements, @sources, cl]) {
        FileUtils.rm @name, verbose: true if File.exist?(@name)
        C8.sh RakeBuilder::ar, 'vsr', @name, *Build[@sources], verbose: true
      }
    end
  end

  def _names_
    if @sources.empty?
      []
    else
      [ @name, @sources ]
    end
  end

  def _build_
    if @sources.empty?
      []
    else
      [ @name ]
    end
  end
end

