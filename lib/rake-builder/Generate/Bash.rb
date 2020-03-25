module Generate
  class Bash
    def initialize
      @d = []
      @indent = 0

      self << "#!/bin/bash"
      self << ""
    end

    def << line
      if line.empty?
        @d << ""
      else
        @d << "#{i}#{line}"
      end

      self
    end

    def to_s
      content = @d.flatten
      if content.last == ""
        content.join("\n")
      else
        content.join("\n") + "\n"
      end
    end

    def indent &block
      @indent += INDENT_PER_LEVEL
      instance_eval &block
    ensure
      @indent -= INDENT_PER_LEVEL
    end

    def if_ condition, &block
      self << "if #{condition}; then"
      indent &block
      self << "fi"
    end

    def function name, &block
      self << "#{name}() {"
      indent &block
      self << "}"
    end

    def source_static fn
      self << "source #{File.expand_path(fn)}"
    end

    def source fn
      if_("[ -f #{File.expand_path(fn)} ]") {
        source_static fn
      }
    end

  private
    INDENT_PER_LEVEL = 2

    def i
      ' ' * @indent
    end
  end

  def bash &block
    o = Bash.new
    o.instance_eval &block
    o.to_s
  end

  module_function :bash
end
