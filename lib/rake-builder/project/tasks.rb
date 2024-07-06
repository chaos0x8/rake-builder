module RakeBuilder
  class Tasks
    include Rake::DSL

    def initialize(default: nil, clean: nil, cmake: nil)
      if default
        desc "Compiles projects: #{__names__(default)}"
        RakeBuilder.multitask default: collect(default, &:collect_dependencies).reduce(Attr::StringContainer.new,
                                                                                       :+).to_a
      end

      if clean
        desc "Cleans projects: #{__names__(clean)}"
        RakeBuilder.task :clean do
          each(clean, &:clean)
        end
      end

      return unless cmake

      desc "Generates CMakeLists.txt for projects: #{cmake.project_name}"
      RakeBuilder.task cmake: collect(cmake, &:collect_dependencies)
        .reduce(Attr::StringContainer.new, :+).to_a
    end

    private

    def each(arg, &block)
      [arg].flatten.compact.each(&block)
    end

    def collect(arg, &block)
      each(arg).collect(&block)
    end

    def __names__(arg)
      collect(arg, &:name).join(', ')
    end
  end

  class MultiPhony < Rake::MultiTask
    def timestamp
      Time.at 0
    end
  end

  class Phony < Rake::Task
    def timestamp
      Time.at 0
    end
  end

  class Task < Rake::Task
    def timestamp
      prerequisite_tasks.collect(&:timestamp).max || Time.now
    end
  end

  class MultiTask < Rake::MultiTask
    def timestamp
      prerequisite_tasks.collect(&:timestamp).max || Time.now
    end
  end

  def self.register(cls, name)
    cls.define_singleton_method(:define_task) do |*args, &block|
      Rake.application.define_task(cls, *args, &block)
    end

    define_singleton_method(name) do |*args, &block|
      cls.define_task(*args, &block)
    end
  end

  register Phony, :phony
  register MultiPhony, :multiphony
  register Task, :task
  register MultiTask, :multitask
end
