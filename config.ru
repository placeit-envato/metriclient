$stdout.sync = true # Sync to stdout for foreman.
$:.unshift File.expand_path(File.dirname(__FILE__))

require "metriclient/api"
require "metriclient/app"
require "rack/cors"

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options], :credentials => false
  end
end

run Rack::URLMap.new \
  "/" => Metriclient::App,
  "/api/v1/" => Metriclient::Api

