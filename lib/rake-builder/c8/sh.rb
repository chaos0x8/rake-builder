autoload :Open3, 'open3'

require_relative 'puts'

require 'pty'

module C8
  def self.sh(*args, verbose: false, silent: false, nonVerboseMessage: nil, **opts)
    if verbose
      C8.puts Shellwords.join(args)
    elsif nonVerboseMessage
      C8.puts nonVerboseMessage
    end

    st = nil

    if silent
      PTY.spawn(*args, opts) do |r, _w, pid|
        lines = Enumerator.new do |e|
          r.each_line do |line|
            e << line
          end
        rescue Errno::EIO
          nil
        end

        _, st = Process.wait2(pid)

        C8.print(lines.to_a.join) if st.exitstatus != 0
      end
    else
      pid, st = Process.wait2(Process.spawn(*args, opts))
    end

    raise "C8.sh failed! [#{Shellwords.join(args)}]" if st.exitstatus != 0

    nil
  end

  def self.script(code)
    C8.puts code

    st = Open3.popen2e('sh') do |stdin, stdout, thread|
      stdin.write code
      stdout.each_line do |line|
        C8.puts line
      end

      thread.value
    end

    rause 'C8.script failed!' if st.exitstatus != 0
  end
end
