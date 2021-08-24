Gem::Specification.new { |s|
  s.name        = 'rake-builder'
  s.version     = '3.3.2'
  s.date        = '2021-08-24'
  s.summary     = "#{s.name} library"
  s.description = "Library for easier rakefile creation"
  s.authors     = ["chaos0x8"]
  s.files       = Dir['lib/**/*.rb']
  s.add_runtime_dependency 'rake'
}
