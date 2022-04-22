#!usr/bin/env ruby

require 'io/console'
require 'pty'

module C8
  module Password
    def self.aquire prompt
      $stdout.print prompt
      $stdin.noecho(&:gets).chomp
    ensure
      $stdout.puts
    end
  end
end
