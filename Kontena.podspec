Pod::Spec.new do |s|
  s.name             = "Kontena"
  s.version          = "0.2.0"
  s.summary          = "A simple Swift implementation of Service Locator / IOC container"
  s.homepage         = "https://github.com/markvaldy/Kontena"
  s.license          = {
    :type => 'MIT',
    :file => 'LICENSE.md'
  }
  s.author           = {
    "Vadym Markov" => "impressionwave@gmail.com"
  }
  s.source           = {
    :git => "https://github.com/markvaldy/Kontena.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/markvaldy'

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.requires_arc = true

  s.source_files = 'Source/**/*.{swift}'
  s.dependency 'TypeHelper', '~> 0.1.2'
  s.frameworks = 'Foundation'
end
