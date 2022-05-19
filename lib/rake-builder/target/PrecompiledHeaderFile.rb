require_relative 'Target'

class PrecompiledHeaderFile < RakeBuilder::Target
  def initialize(*args, **opts)
    warn "#{self.class} is deprecated, use C8.project.precompiled_header instead"
    super(*args, **opts)

    required(:name)

    dir = Names[Directory.new(to_obj(@name))]
    file(to_mf(@name) => Names[dir, @requirements, readMf(to_mf(@name)), @name]) do
      C8.sh RakeBuilder.gpp, *Build[@flags], *Build[@includes],
            '-x', 'c++-header', '-c', @name, '-M', '-MM', '-MF', to_mf(@name),
            verbose: RakeBuilder.verbose, silent: RakeBuilder.silent
    end

    desc @description if @description
    file(to_gch(@name) => Names[dir, @requirements, to_mf(@name), @name].flatten) do
      C8.sh RakeBuilder.gpp, *Build[@flags], *Build[@includes],
            '-x', 'c++-header', '-c', @name, '-o', to_gch(@name),
            verbose: RakeBuilder.verbose, silent: RakeBuilder.silent,
            nonVerboseMessage: "#{RakeBuilder.gpp} #{@name}"
    end
  end

  def _names_
    to_gch(@name)
  end
end
