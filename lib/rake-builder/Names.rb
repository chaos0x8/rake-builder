class Names
  def self.[](*args)
    args.collect { |a|
      if a.nil?
        nil
      elsif a.kind_of? Array
        Names[*a]
      elsif a.respond_to? :_names_
        Names[a._names_]
      else
        a.to_s
      end
    }.flatten.uniq.compact
  end
end
