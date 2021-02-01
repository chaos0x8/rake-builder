require 'optionparser'
require 'forwardable'

module RakeBuilder
  class OptionParser
    extend Forwardable

    def_delegators :@op, :on, :on_head, :on_tail, :to_s, :help, :banner, :banner=, :separator

    def initialize
      Deprecated.deprecated 'RakeBuilder::OptionParser' => 'task(:option, [:value])'
      @op = ::OptionParser.new
      yield self if block_given?
    end

    def parse! argv
      nonOptions, options = extract_(argv)
      nonOptions += @op.parse(options)
      nonOptions
    end

  private
    def extract_ argv
      if sep = argv.index('--')
        options = argv[sep+1..-1]
        argv.slice!(sep..-1)
        [argv, options]
      else
        [argv, []]
      end
    end
  end
end
