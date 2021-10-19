# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = '2048-ruby'
  s.version = '0.1'
  s.licenses = ['MIT']
  s.summary = 'Classic game 2048 in your terminal'
  s.authors = ['anim']
  s.email = 'me@telpart.ru'
  s.files = Dir['lib/**/*.rb']
  s.executables = ['2048']
  s.homepage = 'https://github.com/animotto/2048-ruby'
  s.required_ruby_version = '>= 2.7'
end
