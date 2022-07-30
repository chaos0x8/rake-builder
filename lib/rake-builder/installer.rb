module RakeBuilder
  class Installer
    def initialize
      @mutex = Mutex.new
    end

    def apt_installed?(pkg)
      @mutex.synchronize do
        out, st = Open3.capture2e('dpkg', '-s', pkg)
        st.exitstatus == 0
      end
    end

    def apt_install(*pkgs)
      to_install = pkgs.reject do |pkg|
        apt_installed? pkg
      end

      unless to_install.empty?
        @mutex.synchronize do
          RakeBuilder.sh 'sudo', '-E', 'apt', 'install', *to_install
        end
      end
    end
  end

  @installer = Installer.new

  %w[apt_installed? apt_install].each do |sym|
    define_singleton_method sym do |*args, **opts, &block|
      @installer.send(sym, *args, **opts, &block)
    end
  end
end
