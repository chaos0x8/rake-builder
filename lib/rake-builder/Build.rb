class Build
  def self.[](*args)
    args.collect { |a|
      if a.kind_of? Array
        Build[*a]
      elsif a.respond_to? :_build_
        Build[a._build_]
      elsif a.respond_to? :_names_
        Names[a._names_]
      else
        a.to_s
      end
    }.flatten.uniq.compact
  end
end

