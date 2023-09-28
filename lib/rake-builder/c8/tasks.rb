require 'rake'

module C8
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

  register C8::Phony, :phony
  register C8::MultiPhony, :multiphony
  register C8::Task, :task
  register C8::MultiTask, :multitask
end
