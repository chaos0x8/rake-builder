module RakeBuilder
  module Transform
    def to_obj name
      chExt(name, '.o')
    end

    def to_mf name
      chExt(name, '.mf')
    end

    def to_cl name
      chExt(name, '.cl')
    end

  private
    def chExt(x, ext)
      if x.respond_to?(:collect)
        x.collect { |y| chExt(y, ext) }
      else
        '.obj/' + x.ext(ext)
      end
    end
  end
end
