module RakeBuilder
  class MissingAttribute < RuntimeError
    def initialize attribute
      super("Missing attribute '#{attribute}'")
    end
  end

  class MissingPkg < RuntimeError
    def initialize pkg
      super("Missing pkg '#{pkg}'")
    end
  end

  class PkgsInstalationError < RuntimeError
    def initialize pkgs
      super("Failed to install pkgs #{pkgs.collect { |x| "'#{x}'" }.join(', ')}")
    end
  end
end
