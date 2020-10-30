class Names
  class All
    def self.[](*args)
      args.collect { |a|
        if a.nil?
          nil
        elsif a.kind_of? Array
          Names[*a]
        elsif a.respond_to? :_names_
          Names[a._names_]
        elsif a.kind_of?(String) or a.kind_of?(Symbol)
          if Rake::Task.task_defined?(a)
            [Rake::Task[a].all_prerequisite_tasks.collect(&:to_s), a.to_s]
          else
            a.to_s
          end
        else
          a.to_s
        end
      }.flatten.uniq.compact
    end
  end

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
