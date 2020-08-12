namespace(:examples) {
  task(:default => 'gem:install') {
    Dir['examples/*'].each { |dir|
      Dir.chdir(dir) {
        $stdout.puts '---------------------'
        $stdout.puts "Example: #{File.basename(dir)}"
        $stdout.puts '---------------------'
        sh 'rake', 'clean'
        sh 'rake'
      }
    }
  }
}

desc 'Compiles examples'
task(examples: 'examples:default')
