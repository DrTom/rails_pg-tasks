require 'pg_tasks'
require 'rails'
module PgTasks
  class Railtie < Rails::Railtie
    railtie_name :pg_tasks
    rake_tasks do
      load 'tasks/pg_tasks.rake'
    end
  end
end
