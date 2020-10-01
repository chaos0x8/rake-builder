autoload :Open3, 'open3'

require_relative 'Puts'

module C8
  def self.sh *args, verbose: false, **opts
    C8.puts Shellwords.join(args) if verbose
    unless system(*args, opts)
      raise RuntimeError.new("C8.sh failed! [#{Shellwords.join(args)}]")
    end

    nil
  end
end
