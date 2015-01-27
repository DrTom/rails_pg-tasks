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
    task truncate_tables: [:environment, :load_config] do
      PgTasks.truncate_tables
    end

    namespace :data do
      task dump: [:environment, :load_config] do
        PgTasks.data_dump ENV['FILE']
      end

      task restore: [:environment, :load_config] do
        PgTasks.data_restore ENV['FILE']
      end
    end

    namespace :structure_and_data do
      task dump: [:environment, :load_config] do
        PgTasks.structure_and_data_dump ENV['FILE']
      end

      task restore: [:environment, :load_config] do
        PgTasks.structure_and_data_restore ENV['FILE']
      end
    end
  end
end
