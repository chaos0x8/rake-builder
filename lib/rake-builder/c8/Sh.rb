autoload :Open3, 'open3'

require_relative 'Puts'

require 'pty'

module C8
  def self.sh *args, verbose: false, silent: false, nonVerboseMessage: nil, **opts
    if verbose
      C8.puts Shellwords.join(args)
    elsif nonVerboseMessage
      C8.puts nonVerboseMessage
    end

    st = nil

    if silent
      PTY.spawn(*args, opts) { |r, w, pid|
        lines = Enumerator.new { |e|
          begin
            r.each_line { |line|
              e << line
            }
          rescue Errno::EIO
            nil
          end
        }

        _, st = Process.wait2(pid)

        if st.exitstatus != 0
          C8.print(lines.to_a.join)
        end
      }
    else
      pid, st = Process.wait2(Process.spawn(*args, opts))
    end

    if st.exitstatus != 0
      raise RuntimeError.new("C8.sh failed! [#{Shellwords.join(args)}]")
    end

    nil
  end
end
