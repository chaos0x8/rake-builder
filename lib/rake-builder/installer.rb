module RakeBuilder
  class Installer
    def initialize
      @mutex = Mutex.new
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

    def apt_remove(*pkgs)
      to_remove = pkgs.select do |pkg|
        apt_installed? pkg
      end

      unless to_remove.empty?
        @mutex.synchronize do
          RakeBuilder.sh 'sudo', '-E', 'apt', 'remove', *to_remove
        end
      end
    end

    def gem_install(*pkgs)
      to_install = pkgs.reject do |pkg|
        gem_installed? pkg
      end

      @mutex.synchronize do
        to_install.each do |pkg|
          RakeBuilder.sh 'sudo', '-E', 'gem', 'install', pkg
        end
      end
    end

    def gem_uninstall(*pkgs)
      to_remove = pkgs.select do |pkg|
        gem_installed? pkg
      end

      @mutex.synchronize do
        to_remove.each do |pkg|
          RakeBuilder.sh 'sudo', 'gem', 'uninstall', pkg
        end
      end
    end

    private

    def apt_installed?(pkg)
      @mutex.synchronize do
        out, st = Open3.capture2e('dpkg', '-s', pkg)
        st.exitstatus == 0
      end
    end

    def gem_installed?(pkg)
      out, st = Open3.capture2e('gem', 'list')
      st.exitstatus == 0 && !out.each_line(chomp: true).grep(/^#{pkg}\b/).empty?
    end
  end

  @installer = Installer.new

  %w[apt_install apt_remove gem_install gem_uninstall].each do |sym|
    define_singleton_method sym do |*args, **opts, &block|
      @installer.send(sym, *args, **opts, &block)
    end
  end
end
