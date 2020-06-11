require_relative 'Target'
require_relative '../ComponentList'

class Executable < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = Names[Directory.new(name: @name)]
    cl = RakeBuilder::ComponentList.new(name: to_cl(@name), sources: @sources)

    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, @libs, cl]) {
      sh "#{RakeBuilder::gpp} #{_build_join_(@flags)} #{_build_join_(@sources)} -o #{@name} #{_build_join_(@libs)}".squeeze(' ')
    }
  end

  def _names_
    [ @name, @sources, @libs ]
  end
end

