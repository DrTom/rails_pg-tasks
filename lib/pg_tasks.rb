#--
# Copyright (c) 2015 Thomas Schank
#
# Released to the public under the terms of the MIT license.
# See MIT-LICENSE.
#
#++

require 'active_record/tasks/database_tasks'
require 'active_record/tasks/postgresql_database_tasks'

module PgTasks
  require 'pg_tasks/railtie' if defined?(Rails)

  DEFAULT_BINARY_DATA_FILE_NAME = 'data.pgbin'.freeze
  DEFAULT_BINARY_STRUCTURE_AND_DATA_FILE_NAME = 'structure_and_data.pgbin'.freeze
  DEFAULT_SQL_STRUCTURE_AND_DATA_FILE_NAME = 'structure_and_data.sql'.freeze

  class << self
    %w(data_restore).each do |method_name|
      define_method method_name do |filename = nil|
        ActiveRecord::Tasks::DatabaseTasks \
          .perform_pg_db_task_for_config_and_filename \
            method_name, current_config,
            filename_or_default_binary_data_file(filename)
      end
    end

    %w(structure_and_data_dump structure_and_data_dump_sql structure_and_data_restore)
    .each do |method_name|
      define_method method_name do |filename = nil|
        ActiveRecord::Tasks::DatabaseTasks \
          .perform_pg_db_task_for_config_and_filename \
            method_name, current_config,
            filename_or_default_binary_structure_and_data_file(filename)
      end
    end

    def truncate_tables
      ActiveRecord::Base.connection.tap do |connection|
        connection.tables.reject{|tn| tn == 'schema_migrations'}
          .reject{|tn| tn == 'ar_internal_metadata'}
          .join(', ').tap do |tables|
          connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
        end
      end
    end

    def terminate_connections
      ActiveRecord::Tasks::DatabaseTasks.terminate_connections current_config
    end

    private

    def current_config
      ActiveRecord::Tasks::DatabaseTasks.current_config
    end

    def filename_or_default(filename, default)
      (filename.present? && filename) \
        || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, default)
    end

    def filename_or_default_binary_data_file(filename)
      filename_or_default(filename, DEFAULT_BINARY_DATA_FILE_NAME)
    end

    def filename_or_default_binary_structure_and_data_file(filename)
      filename_or_default(filename, DEFAULT_BINARY_STRUCTURE_AND_DATA_FILE_NAME)
    end

    def filename_or_default_sql_structure_and_data_file(filename)
      filename_or_default(filename, DEFAULT_SQL_STRUCTURE_AND_DATA_FILE_NAME)
    end

  end
end

module ActiveRecord
  module Tasks
    class PostgreSQLDatabaseTasks

      def data_restore(filename)
        shell_filename= Shellwords.escape filename.to_s
        list_cmd = "pg_restore -l #{shell_filename}"
        pg_list = `#{list_cmd}`
        raise "Command #{list_cmd} failed " if $?.exitstatus != 0
        restore_list = pg_list.split(/\n/) \
          .reject{|l| l =~ /TABLE DATA .* schema_migrations/}
          .reject{|l| l =~ /TABLE DATA .* ar_internal_metadata/}
          .join("\n")
        begin
          restore_list_file = Tempfile.new 'pg_restore_list'
          restore_list_file.write restore_list

          set_psql_env
          command = 'pg_restore --data-only --exit-on-error ' \
            ' --disable-triggers --single-transaction --no-privileges --no-owner ' \
            " -d #{Shellwords.escape(configuration_hash[:database])} " \
            " --use-list=#{restore_list_file.path} " \
            " #{shell_filename}"
          unless Kernel.system(command)
            raise 'Error during data_restore '
          else
            $stdout.puts "Data from '#{filename}' has been restored to \
                        '#{configuration_hash[:database]}'"
          end
        ensure
          restore_list_file.close
          restore_list_file.unlink
        end
      end

      def structure_and_data_dump(filename, plain_text = false)
        set_psql_env
        command = "pg_dump -x -O \
        -F #{plain_text ? 'p' : 'c'} \
        -f #{Shellwords.escape(filename)} \
        #{Shellwords.escape(configuration_hash[:database])}"
        unless Kernel.system(command)
          raise 'Error during structure_and_data_dump'
        else
          $stdout.puts 'Structure and data of ' \
            "'#{configuration_hash[:database]}' has been dumped to '#{filename}'"
        end
      end

      def structure_and_data_dump_sql(filename)
        structure_and_data_dump(filename, true)
      end

      def structure_and_data_restore(filename)
        set_psql_env
        command = 'pg_restore --disable-triggers --exit-on-error ' \
          '--single-transaction -x -O -d ' \
          "#{Shellwords.escape(configuration_hash[:database])} " \
          "#{Shellwords.escape(filename.to_s)}"
        unless Kernel.system(command)
          raise 'Error during structure_and_data_restore '
        else
          $stdout.puts "Structure and data of '#{configuration_hash[:database]}' " \
            "has been restored to '#{filename}'"
        end
      end

      def terminate_connections
        set_psql_env
        database = configuration_hash[:database]
        command = "psql -c \"SELECT pg_terminate_backend(pg_stat_activity.pid) " \
          ' FROM pg_stat_activity ' \
          "WHERE pg_stat_activity.datname = '#{database}' " \
          " AND pid <> pg_backend_pid();\" '#{database}'"
        unless Kernel.system(command)
          raise 'Error during terminate_connections'
        else
          $stdout.puts "Connections to '#{database}' have been terminated."
        end
      end
    end
  end
end

module ActiveRecord
  module Tasks
    module DatabaseTasks
      def perform_pg_db_task_for_config_and_filename(task_name, *arguments)
        configuration = arguments.first
        filename = arguments.delete_at(1)
        hash_config =
          ActiveRecord::DatabaseConfigurations::HashConfig.new("test", "primary", configuration)
        class_for_adapter(hash_config.configuration_hash[:adapter])
          .new(hash_config)
          .send(task_name, filename)
      rescue ActiveRecord::NoDatabaseError
        $stderr.puts "Database '#{hash_config.configuration_hash[:database]}' does not exist"
      rescue Exception => error
        $stderr.puts error, *(error.backtrace)
        raise error
      end

      def terminate_connections(*arguments)
        configuration = arguments.first
        hash_config =
          ActiveRecord::DatabaseConfigurations::HashConfig.new("test", "primary", configuration)
        class_for_adapter(hash_config.configuration_hash[:adapter]).new(hash_config).send :terminate_connections
      end
    end
  end
end
