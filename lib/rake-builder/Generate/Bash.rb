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

    def if_else condition, block, else_:
      self << "if #{condition}; then"
      indent &block
      self << "else"
      indent &else_
      self << "fi"
    end

    def function name, &block
      self << "#{name}() {"
      indent &block
      self << "}"
    end

    def source_static fn
      self << "source #{Shellwords.escape(File.expand_path(fn))}"
    end

    def source fn
      if_("[ -f #{Shellwords.escape(File.expand_path(fn))} ]") {
        source_static fn
      }
    end

    def cd fn
      self << "cd #{Shellwords.escape(File.expand_path(fn))}"
    end

    def apt_install pkg
      if_("! dpkg -s #{Shellwords.escape(pkg)} > /dev/null 2> /dev/null") {
        self << "sudo apt install -y #{Shellwords.escape(pkg)}"
      }
    end

    def path fn
      self << "export PATH=#{Shellwords.escape(File.expand_path(fn))}:$PATH"
    end

    def variable hash = Hash.new
      hash.each { |name, val|
        self << "#{Shellwords.escape(name)}=#{Shellwords.escape(val)}"
      }
    end

    def export hash = Hash.new
      hash.each { |name, val|
        self << "export #{Shellwords.escape(name)}=#{Shellwords.escape(val)}"
      }
    end

    def local hash = Hash.new
      hash.each { |name, val|
        self << "local #{Shellwords.escape(name)}=#{Shellwords.escape(val)}"
      }
    end

    def echo txt
      self << "echo #{Shellwords.escape(txt)}"
    end

    def declared? var
      "declare -p #{Shellwords.escape(var)} > /dev/null 2> /dev/null"
    end

    def complete name, comp
      function("_#{name}") {
        self << "local cur=\"${COMP_WORDS[COMP_CWORD]}\""
        if comp.kind_of? Hash
          self << "local prev=\"${COMP_WORDS[COMP_CWORD-1]}\""
          self << ""
          self << "case \"${prev}\" in"
          indent {
            comp.each { |key, vals|
              if vals
                self << "#{key})"
                indent {
                  self << "COMPREPLY=($(compgen -W \"#{vals.join(' ')}\" -- \"${cur}\"))"
                  self << "return 0"
                  self << ";;"
                }
              end
            }
            self << "*)"
            indent {
              self << ";;"
            }
          }
          self << "esac"
          self << ""
          self << "COMPREPLY=($(compgen -W \"#{comp.keys.join(' ')}\" -- \"${cur}\"))"
        elsif comp.size > 1
          self << ""
          self << "COMPREPLY=($(compgen -W \"#{comp.join(' ')}\" -- \"${cur}\"))"
        else
          self << ""
          if_("[ $COMP_CWORD -eq 1 ]") {
            self << "COMPREPLY=($(compgen -W \"#{comp.join(' ')}\" -- \"${cur}\"))"
            self << "return 0"
          }
          self << ""
          self << "COMPREPLY=()"
        end
      }
      self << ""
      self << "complete -F _#{name} #{name}"
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
