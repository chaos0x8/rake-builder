module RakeBuilder
  module Transform
    def to_obj name
      adExt(name, '.o')
    end

    def to_mf name
      adExt(name, '.mf')
    end

    def to_cl name
      adExt(name, '.cl')
    end

    def to_gch name
      adExt(name, '.gch', dir: '.')
    end

  private
    def adExt(x, ext, dir: RakeBuilder.outDir)
      if x.respond_to?(:collect)
        x.collect { |y| adExt(y, ext, dir: dir) }
      else
        if dir == '.'
          "#{x}#{ext}"
        else
          File.join(dir, "#{x}#{ext}")
        end
      end
    end
  end
end
