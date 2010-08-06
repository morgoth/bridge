version = File.read(File.expand_path("../RAILS_VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'rails'
  s.version     = version
  s.summary     = 'Full-stack web application framework.'
  s.description = 'Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.author            = 'David Heinemeier Hansson'
  s.email             = 'david@loudthinking.com'
  s.homepage          = 'http://www.rubyonrails.org'
  s.rubyforge_project = 'rails'

  s.bindir             = 'bin'
  s.executables        = ['rails']
  s.default_executable = 'rails'

  s.add_dependency('activesupport',  version)
  s.add_dependency('actionpack',     version)
  s.add_dependency('activerecord',   version)
  s.add_dependency('activeresource', version)
  s.add_dependency('actionmailer',   version)
  s.add_dependency('railties',       version)
  s.add_dependency('bundler',        '>= 1.0.0.rc.2')
end
