class Directory
  include Rake::DSL

  attr_reader :name

  @@definedDirs = []

  def initialize(name:)
    @name = File.dirname(name)

    yield(self) if block_given?

    unless @@definedDirs.include?(@name) and @name != '.'
      directory(@name)
      @@definedDirs << @name
    end
  end

  def _names_
    (@name == '.') ? [] : @name
  end
end

