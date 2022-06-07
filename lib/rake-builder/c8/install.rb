module C8
  module Install
    def mutex
      @@mutex ||= Mutex.new
    end

    def apt_installed?(pkg)
      out, st = Open3.capture2e('dpkg', '-s', pkg)
      st.exitstatus == 0
    end

    def apt_install(*pkgs)
      mutex.synchronize do
        to_install = pkgs.reject do |pkg|
          apt_installed? pkg
        end

        C8.sh 'sudo', '-E', 'apt', 'install', *to_install unless to_install.empty?
      end
    end

    def apt_remove(*pkgs)
      mutex.synchronize do
        to_remove = pkgs.select do |pkg|
          apt_installed? pkg
        end

        C8.sh 'sudo', '-E', 'apt', 'remove', *to_remove unless to_remove.empty?
      end
    end

    def gem_installed?(pkg)
      out, st = Open3.capture2e('gem', 'list')
      st.exitstatus == 0 && !out.each_line(chomp: true).grep(/^#{pkg}\b/).empty?
    end

    def gem_install(*pkgs)
      mutex.synchronize do
        to_install = pkgs.reject do |pkg|
          gem_installed? pkg
        end

        to_install.each do |pkg|
          C8.sh 'sudo', '-E', 'gem', 'install', pkg
        end
      end
    end

    def gem_uninstall(*pkgs)
      mutex.synchronize do
        to_remove = pkgs.select do |pkg|
          gem_installed? pkg
        end

        to_remove.each do |pkg|
          C8.sh 'sudo',  'gem', 'uninstall', pkg
        end
      end
    end
  end
end
