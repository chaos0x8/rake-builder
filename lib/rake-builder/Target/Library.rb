require_relative 'Target'
require_relative '../ComponentList'

class Library < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = Names[Directory.new(name: @name)]
    cl = RakeBuilder::ComponentList.new(name: to_cl(@name), sources: @sources)

    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, cl]) {
      sh "#{RakeBuilder::ar} vsr #{@name} #{_build_join_(@sources)}"
    }
  end

  def _build_
    Build[@name]
  end
end

