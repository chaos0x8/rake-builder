require_relative '../Colorize'

module Deprecated
  def self.deprecated **opts
    opts.each { |key, replacement|
      $stdout.puts "#{'WARNING:'.yellow} #{key.to_s.red} is deprecated, please use #{replacement.to_s.green} instead"
    }
  end
end
