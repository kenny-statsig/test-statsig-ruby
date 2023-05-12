Gem::Specification.new do |s|
  s.name        = 'test-statsig'
  s.version     = '0.0.0'
  s.summary     = 'Testing statsig'
  s.description = 'Testing statsig'
  s.authors     = ['Kenny']
  # s.email       = 'support@statsig.com'
  # s.homepage    = 'https://rubygems.org/gems/statsig'
  # s.license     = 'ISC'
  s.files       = Dir['.']
  s.required_ruby_version = '>= 2.5.0'
  s.rubygems_version = '>= 2.5.0'
  # s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "webmock", "~> 3.13"
  s.add_development_dependency "minitest", "~> 5.14"
  # s.add_development_dependency "spy", "~> 1.0"
  # s.add_development_dependency "sorbet", '0.5.10461'
  # s.add_development_dependency "tapioca", '~> 0.4.27'
  s.add_development_dependency 'sinatra', '~> 2.2'
  s.add_development_dependency 'puma', '~> 6.0'
  # s.add_development_dependency 'statsig', '~> 1.24.6'
  # s.add_runtime_dependency 'user_agent_parser', '~> 2.7'
  # s.add_runtime_dependency 'http', '>= 4.4', '< 6.0'
  # s.add_runtime_dependency 'ip3country', '0.1.1'
  # s.add_runtime_dependency 'sorbet-runtime', '~> 0.5.10461'
  # s.add_runtime_dependency 'concurrent-ruby', '~> 1.1'
end
