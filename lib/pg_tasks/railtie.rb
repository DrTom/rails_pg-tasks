#--
# Copyright (c) 2015 Thomas Schank
#
# Released to the public under the terms of the MIT license.
# See MIT-LICENSE.
#
#++

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
