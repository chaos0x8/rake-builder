require_relative 'Target'

class HeaderFile < RakeBuilder::Target
  def initialize(*args, **opts)
    warn "#{self.class} is deprecated, use C8.project.header instead"
    super(*args, **opts)

    required(:name)

    dir = Names[Directory.new(to_obj(@name))]
    file(to_mf(@name) => Names[dir, @requirements, readMf(to_mf(@name)), @name]) do
      C8.sh RakeBuilder.gpp, *Build[@flags], *Build[@includes],
            '-x', 'c++-header', '-c', @name, '-M', '-MM', '-MF', to_mf(@name),
            verbose: RakeBuilder.verbose, silent: RakeBuilder.silent
    end

    desc @description if @description
    file(to_obj(@name) => Names[dir, @requirements, to_mf(@name), @name]) do
      r, w = IO.pipe

      w.write "#include \"#{File.expand_path(@name)}\""
      w.close

      begin
        C8.sh RakeBuilder.gpp, *Build[@flags], *Build[@includes],
              '-x', 'c++', '-c', '-', '-o', to_obj(@name), in: r,
                                                           verbose: RakeBuilder.verbose, silent: RakeBuilder.silent,
                                                           nonVerboseMessage: "#{RakeBuilder.gpp} #{@name}"
      ensure
        r.close
      end
    end
  end

  def _names_
    to_obj(@name)
  end
end
