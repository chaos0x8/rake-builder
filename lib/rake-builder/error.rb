module RakeBuilder
  class Error < RuntimeError
  end

  class MissingPkgError < Error
    def initialize(pkg)
      super "Package `#{pkg}` is missing!"
    end
  end
end
