namespace(:examples) {
  task(:default => 'gem:install') {
    separator = '---------------------'
    info = []

    Dir['examples/*'].each { |dir|
      Dir.chdir(dir) {
        $stdout.puts separator
        $stdout.puts "Example: #{File.basename(dir)}"
        $stdout.puts separator
        sh 'rake', 'clean'
        sh 'rake'
        info << "Example: #{File.basename(dir)} => OK"
      }
    }

    $stdout.puts separator
    $stdout.puts info
    $stdout.puts separator
  }
}

desc 'Compiles examples'
task(examples: 'examples:default')
