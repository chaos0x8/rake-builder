gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../lib/rake-builder'

RSpec::Matchers.define(:when_parsed) { |*args|
  match { |parser|
    @args = args.clone
    @expected_non_options ||= []
    @expected_options ||= {}
    @actual_non_options = parser.parse!(args)
    @actual_non_options == @expected_non_options && options == @expected_options
  }

  chain(:options_are) { |v|
    @expected_options = v
  }

  chain(:non_options_are) { |*v|
    @expected_non_options = v
  }

  failure_message {
    if @actual_non_options != @expected_non_options
      "expected non options [#{@expected_non_options.join(', ')}], but got: [#{@actual_non_options.join(', ')}]"
    elsif options != @expected_options
      "expected options #{@expected_options}, but got: #{options}"
    end
  }

  description {
    "return non options [#{@expected_non_options.join(', ')}] and options #{@expected_options} when parsed '#{(@args||args).join(' ')}'"
  }
}

RSpec::Matchers.define(:have_help) {
  match { |parser|
    parser.help == parser.to_s and parser.help == @expected
  }

  chain(:eq) { |expected|
    @expected = expected
  }

  failure_message { |parser|
    if parser.help != parser.to_s
      "expected to have same help and to_s, but they are different"
    else
      "expected to have help eq to\n#{@expected.inspect}, but it is\n#{parser.help.inspect}"
    end
  }

  description {
    "have help eq #{@expected.gsub("\n", ' ').squeeze(' ').strip}"
  }
}

describe(RakeBuilder::OptionParser) {
  let(:options) { Hash.new }

  subject {
    RakeBuilder::OptionParser.new { |op|
      { help: '--help', foo: '--foo V', bar: '--[no-]bar' }.each { |tag, option|
        op.on(option) { |v|
          options[tag] = v
        }
      }
    }
  }

  it {
    help = "Usage: rspec [options]\n" +
    "        --help\n" +
    "        --foo V\n" +
    "        --[no-]bar\n"

   should have_help.eq(help)
  }

  it {
    should when_parsed('--help').non_options_are('--help')
  }

  it {
    should when_parsed('arg1', '--lol', '--', '--help', '--foo', 'hello', 'arg2').
      non_options_are('arg1', '--lol', 'arg2').
      options_are({help: true, foo: 'hello'})
  }

  [:on, :on_head, :on_tail, :to_s, :help, :banner, :banner=, :separator].each { |method|
    it { should respond_to(method) }
  }

  context('advanced') {
    subject {
      RakeBuilder::OptionParser.new { |op|
        op.on('--env ENV', [:a, :b], 'sets env') { |v|
          options[:env] = v
        }
      }
    }

    it {
      help = "Usage: rspec [options]\n" +
      "        --env ENV                    sets env\n"

     should have_help.eq(help)
    }

    it {
      should when_parsed('--', '--env', 'a', 'lol').
        non_options_are('lol').
        options_are({env: :a})
    }
  }
}

