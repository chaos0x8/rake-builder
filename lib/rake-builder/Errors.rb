module RakeBuilder
  class Error < RuntimeError
    def initialize msg
      super(msg)
    end
  end

  class MissingAttribute < RakeBuilder::Error
    def initialize attribute
      super("Missing attribute '#{attribute}'")
    end
  end

  class AttributeAltError < RakeBuilder::Error
    def initialize *attributes
      super("One of the: #{attributes.join(', ')} must be present")
    end
  end

  class MissingPkg < RakeBuilder::Error
    def initialize pkg
      super("Missing pkg '#{pkg}'")
    end
  end

  class PkgsInstalationError < RakeBuilder::Error
    def initialize pkgs
      super("Failed to install pkgs #{pkgs.collect { |x| "'#{x}'" }.join(', ')}")
    end
  end
end
