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
end
