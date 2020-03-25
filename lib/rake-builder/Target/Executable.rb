require_relative 'Target'

class Executable < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = Names[Directory.new(name: @name)]
    desc @description if @description
    file(@name => Names[dir, @requirements, @sources, @libs]) {
      sh "#{RakeBuilder::gpp} #{_build_join_(@flags)} #{_build_join_(@sources)} -o #{@name} #{_build_join_(@libs)}".squeeze(' ')
    }
  end

  def _names_
    [ @name, @sources, @libs ]
  end
end

