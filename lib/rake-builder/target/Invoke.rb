require_relative '../c8/Task'
require_relative '../array-wrapper/Requirements'
require_relative '../Utility'

class Invoke
  include RakeBuilder::Utility
  include Rake::DSL

  attr_accessor :name, :description
  attr_reader :requirements

  def initialize(name: nil, requirements: [], description: nil)
    extend RakeBuilder::Desc

    @name = name
    @requirements = RakeBuilder::Requirements.new(requirements)
    @description = description

    yield(self) if block_given?

    required(:name)

    desc @description if @description
    C8.phony(@name) {
      Names[@requirements].each { |req|
        Rake::Task[req].invoke
      }
    }
  end

  def _names_
    @name
  end
end


