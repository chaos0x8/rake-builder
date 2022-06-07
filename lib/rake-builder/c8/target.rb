require_relative 'project_phony'

module C8
  class Target < C8::Project::Phony
    def initialize(*args, **opts, &block)
      warn "#{self.class} is deprecated, use C8::Project::Phony instead"
      super(*args, **opts, &block)
    end
  end

  def self.target(*args, **opts, &block)
    warn 'C8.target is deprecated, use C8::Project::Phony.new instead'
    C8::Project::Phony.new(*args, **opts, &block)
  end
end
