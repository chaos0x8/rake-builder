require_relative 'Utility'
require_relative 'Transform'
require_relative 'Directory'

class GeneratedFile
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :code, :description, :requirements

  def initialize(name: nil, code: nil, description: nil, requirements: [])
    @name = name
    @code = code
    @requirements = RakeBuilder::Requirements.new(requirements)
    @description = description

    yield(self) if block_given?

    required(:name, :code)

    dir = Names[Directory.new(name: @name)]
    desc @description if @description
    file(@name => Names[dir, @requirements]) {
      @code.call(@name)
    }
  end

  alias_method :_names_, :name
end

