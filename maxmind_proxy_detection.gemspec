Gem::Specification.new do |s|
  s.name        = 'maxmind_proxy_detection'
  s.version     = '0.0.1'

  s.summary     = "Wrapper for MaxMind's Proxy Detection service"
  s.description = "A wrapper for MaxMind's Proxy Detection service."
  s.homepage    = 'https://github.com/eric-smartlove/maxmind_proxy_detection'
  s.author      = 'Eric'
  s.email       = 'eric.github@smartlove.fr'
  s.license     = 'MIT'

  s.files                    = Dir['lib/*.rb']
  s.requirements             = 'A MaxMind account with a subscription for Proxy Detection service'
  s.add_runtime_dependency     'excon'
  s.add_development_dependency 'minitest-reporters'
  # With minitest 5, each test raises "NoMethodError: undefined method `assertions'", don't know why.
  s.add_development_dependency 'minitest', '~>4.0'
end
