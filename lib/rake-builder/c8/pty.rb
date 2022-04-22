#!usr/bin/env ruby

require 'io/console'
require 'pty'

autoload :StringIO, 'stringio'

module C8
  module Pty
    module Detail
      def matches text, matcher
        if matcher.respond_to? :call
          matcher.call(text)
        else
          matcher == text
        end
      end

      def evaluate text
        if text.respond_to? :call
          text.call
        else
          text
        end
      end

      module_function :matches, :evaluate
    end

    def self.spawn(args:, expects:, out: $stdout)
      pid, st = nil, nil

      PTY.spawn(*args) { |r, w, pid|
        line = ''

        begin
          while c = r.getc
            if c == "\n" or c == "\r"
              line = ''
            else
              line += c
            end

            out.print c

            expects.each { |k, v|
              if Detail.matches(line, k)
                w.puts Detail.evaluate(v)
                break
              end
            }
          end
        rescue Errno::EIO
          nil
        end

        pid, st = Process.wait2(pid)
      }

      [pid, st]
    end

    def self.capture(args:, expects:)
      out = StringIO.new
      pid, st = C8::Pty.spawn(args: args, expects: expects, out: out)
      [out.string, st]
    end
  end
end
