module RakeBuilder
  class Error < RuntimeError
    def initialize msg
      super(msg)
    end
  end

  class UnknownOption < RakeBuilder::Error
    def initialize option, value
      super("Unknown #{option} '#{value}'")
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

  class AttributeValueError < RakeBuilder::Error
    def initialize attribute
      super("Attribute #{attribute} has incorrect value")
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
