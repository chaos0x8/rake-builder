autoload :Open3, 'open3'

require_relative 'Puts'

module C8
  def self.sh *args, verbose: false, silent: false, nonVerboseMessage: nil, **opts
    if verbose
      C8.puts Shellwords.join(args)
    elsif nonVerboseMessage
      C8.puts nonVerboseMessage
    end

    st = nil

    if silent
      out, st = Open3.capture2e(*args, opts)
      C8.print out if st.exitstatus != 0
    else
      pid, st = Process.wait2(Process.spawn(*args, opts))
    end

    if st.exitstatus != 0
      raise RuntimeError.new("C8.sh failed! [#{Shellwords.join(args)}]")
    end

    nil
  end
end
