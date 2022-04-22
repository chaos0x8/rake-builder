module C8
  @@mutex = Mutex.new

  def self.puts *args
    @@mutex.synchronize {
      $stdout.puts *args
    }
  end

  def self.print *args
    @@mutex.synchronize {
      $stdout.print *args
    }
  end
end
