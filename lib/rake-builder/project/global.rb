require 'securerandom'

module RakeBuilder
  @@random_ = []

  def self.random_task
    val = ''
    loop do
      val += "task_#{SecureRandom.hex}"
      break unless @@random_.include?(val)
    end
    @@random_ << val
    val
  end
end
