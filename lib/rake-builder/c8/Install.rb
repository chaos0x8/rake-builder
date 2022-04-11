module C8
  module Install
    def mutex
      @@mutex ||= Mutex.new
    end

    def apt_install(*pkgs)
      mutex.synchronize do
        to_install = pkgs.reject do |pkg|
          pid, st = Process.wait2(Process.spawn('dpkg', '-s', pkg, %i[out err] => '/dev/null'))
          st.exitstatus == 0
        end

        sh 'sudo', '-E', 'apt', 'install', *to_install unless to_install.empty?
      end
    end

    def gem_install(*pkgs)
      mutex.synchronize do
        out, st = Open3.capture2e('gem', 'list')

        to_install = pkgs.reject do |pkg|
          st.exitstatus == 0 && !out.each_line(chomp: true).grep(/^#{pkg}\b/).empty?
        end

        to_install.each do |pkg|
          sh 'sudo', '-E', 'gem', 'install', pkg
        end
      end
    end
  end
end
