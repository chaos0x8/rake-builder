#!/usr/bin/ruby

class String
    def escape(code)
        "\e[#{code}m#{self}\e[0m"
    end

    def bold
        escape(1)
    end

    def faint
        escape(2)
    end

    def italic
        escape(3)
    end

    def red
        escape(31)
    end

    def green
        escape(32)
    end

    def yellow
        escape(33)
    end

    def blue
        escape(34)
    end

    def magenta
        escape(35)
    end

    def cyan
        escape(36)
    end

    def white
        escape(37)
    end
end
