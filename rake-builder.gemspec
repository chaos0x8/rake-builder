Gem::Specification.new { |s|
  s.name        = 'rake-builder'
  s.version     = '3.4.7'
  s.date        = '2022-04-26'
  s.summary     = "#{s.name} library"
  s.description = "Library for easier rakefile creation"
  s.authors     = ["chaos0x8"]
  s.files       = Dir['lib/**/*.rb']
  s.add_runtime_dependency 'rake'
}
