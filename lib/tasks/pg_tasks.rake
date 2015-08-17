#--
# Copyright (c) 2015 Thomas Schank
#
# Released to the public under the terms of the MIT license.
# See MIT-LICENSE.
#
#++

require 'pg_tasks'

namespace :db do
  namespace :pg do
    desc 'Truncate all tables but schema_migrations'
    task truncate_tables: [:environment, :load_config] do
      PgTasks.truncate_tables
    end

    desc 'Terminate forcefully all connections to the database'
    task terminate_connections: [:environment, :load_config] do
      PgTasks.terminate_connections
    end

    namespace :data do
      desc "Call pg_dump to dump data without structure and without schema_migrations, honors ENV['FILE']"
      task dump: [:environment, :load_config] do
        PgTasks.data_dump ENV['FILE']
      end

      desc "Call pg_restore with parameters apt to load dumps w.o. structure, honors ENV['FILE']"
      task restore: [:environment, :load_config] do
        PgTasks.data_restore ENV['FILE']
      end
    end

    namespace :structure_and_data do
      desc "Call pg_dump to dump all data and structure, honors ENV['FILE']"
      task dump: [:environment, :load_config] do
        PgTasks.structure_and_data_dump ENV['FILE']
      end

      desc "Call pg_restore with parameters apt to load data and structure, honors ENV['FILE']"
      task restore: [:environment, :load_config] do
        PgTasks.structure_and_data_restore ENV['FILE']
      end
    end
  end
end
