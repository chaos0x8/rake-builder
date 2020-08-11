module C8
  class Task < Rake::Task
    def timestamp
      prerequisite_tasks.collect(&:timestamp).max || Time.now
    end

    class << self
      def define_task(*args, &block)
        Rake.application.define_task(self, *args, &block)
      end
    end
  end

  class MultiTask < Rake::MultiTask
    def timestamp
      prerequisite_tasks.collect(&:timestamp).max || Time.now
    end

    class << self
      def define_task(*args, &block)
        Rake.application.define_task(self, *args, &block)
      end
    end
  end

  def self.task(*args, &block)
    C8::Task.define_task(*args, &block)
  end

  def self.multitask(*args, &block)
    C8::MultiTask.define_task(*args, &block)
  end
end
