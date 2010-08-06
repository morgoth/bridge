version = File.read(File.expand_path("../../RAILS_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'activeresource'
  s.version     = version
  s.summary     = 'REST modeling framework (part of Rails).'
  s.description = 'REST on Rails. Wrap your RESTful web app with Ruby classes and work with them like Active Record models.'

  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'David Heinemeier Hansson'
  s.email             = 'david@loudthinking.com'
  s.homepage          = 'http://www.rubyonrails.org'
  s.rubyforge_project = 'activeresource'

  s.files        = Dir['CHANGELOG', 'README.rdoc', 'examples/**/*', 'lib/**/*']
  s.require_path = 'lib'

  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README.rdoc )
  s.rdoc_options.concat ['--main',  'README.rdoc']

  s.add_dependency('activesupport', version)
  s.add_dependency('activemodel',   version)
end
