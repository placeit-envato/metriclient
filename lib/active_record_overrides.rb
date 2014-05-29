class ActiveRecord::Base
  self.connection_handler = ::Metriclient::DatabaseManager.instance
end
