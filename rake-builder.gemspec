Gem::Specification.new { |s|
  s.name        = 'rake-builder'
  s.version     = '8.0.3'
  s.date        = '2023-09-30'
  s.summary     = "#{s.name} library"
  s.description = "Library for building simple C++ applications"
  s.authors     = ["chaos0x8"]
  s.files       = Dir['lib/**/*.rb']
  s.add_runtime_dependency 'rake'
}
