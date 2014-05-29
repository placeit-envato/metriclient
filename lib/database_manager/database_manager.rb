require 'active_record'
require 'singleton'

module Metriclient
  class DatabaseManagerConfigNotFoundError < StandardError
  end

  class DatabaseManager < ActiveRecord::ConnectionAdapters::ConnectionHandler
    include Singleton

    attr_accessor :subdomain, :pool
    attr_reader :path, :environment

    def initialize
      @path = "#{APP_ROOT}/config/database.yml"
      @environment = ENV["RACK_ENV"] || "development"
      # by default, set default as subdomain
      self.subdomain = 'default'
      super
      setup
    end

    def retrieve_connection_pool klass
      self.pool[subdomain]
    end

    private
      def init_pool
        @pool ||= {}
      end

      def setup
        init_pool
        databases = read_database_config
        add_databases_to_pool(databases)
      end

      def read_database_config path=self.path
        if File.exists? path
          YAML.load_file path
        else
          raise DatabaseManagerConfigNotFoundError
        end
      end

      def add_databases_to_pool databases_config
        databases_config.each do |subdomain, config|
          add_database_to_pool subdomain, config
        end
      end

      def add_database_to_pool subdomain, config
        environment_config = config[self.environment]
        pool[subdomain] = create_connection subdomain, environment_config
      end

      def create_connection subdomain, config
        resolver = ActiveRecord::Base::ConnectionSpecification::Resolver.new(config, nil)
        establish_connection(subdomain, resolver.spec)
      end
  end
end
