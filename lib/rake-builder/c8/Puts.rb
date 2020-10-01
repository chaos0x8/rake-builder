module C8
  @@mutex = Mutex.new

  def self.puts *args
    @@mutex.synchronize {
      $stdout.puts *args
    }
  end
end
