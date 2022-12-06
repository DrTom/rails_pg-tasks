$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'pg_tasks/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'pg_tasks'
  s.version     = PgTasks::VERSION
  s.authors     = ['Thomas Schank']
  s.email       = ['DrTom@schank.ch']
  s.homepage    = 'https://github.com/DrTom/rails_pg-tasks'
  s.summary     = 'PostgreSQL Tasks and Functions for Ruby on Rails'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 6.1.0'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rubocop'
end
