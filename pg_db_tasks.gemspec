$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pg_db_tasks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pg_db_tasks"
  s.version     = PgDbTasks::VERSION
  s.authors     = ["Thomas Schank"]
  s.email       = ["DrTom@schank.ch"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PgDbTasks."
  s.description = "TODO: Description of PgDbTasks."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.8"

  s.add_development_dependency "pg"
end
