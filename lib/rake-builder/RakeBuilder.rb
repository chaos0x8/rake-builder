module RakeBuilder
  @@gpp = 'g++'
  @@ar = 'ar'

  def self.gpp
    @@gpp
  end

  def self.gpp= value
    @@gpp = value
  end

  def self.ar
    @@ar
  end

  def self.ar= value
    @@ar = value
  end

  module Desc
    def self.extended cls
      cls.instance_eval {
        @description = nil
      }
    end

    attr_accessor :description

    def desc= v
      @description = v
    end
  end
end
