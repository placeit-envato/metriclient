require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'yajl'
require 'multi_json'

require 'lib/metriclient.rb'

module Metriclient
  class Api < Sinatra::Base

    # Configuration for the reloader on dev
    configure :development do
      register Sinatra::Reloader
      also_reload "lib/metriclient.rb"
    end

    # API configuration
    configure do
      MultiJson.engine = :yajl

      enable :logging
      enable :raise_errors

      set :protection, :except => :json_csrf
      # set :protection, :except => [:json_csrf, :http_options]
    end

    # Sinatra JSON Helper
    helpers Sinatra::JSON

    before do
      route_split = request.host.split('.')
      if route_split.length > 2
        # naive method to get subdomain
        subdomain = route_split.first
        Metriclient::DatabaseManager.instance.subdomain = subdomain
      else
        Metriclient::DatabaseManager.instance.subdomain = 'default'
      end
    end

    # The routes
    get '/' do
      json ["Metriclient::Api v1. Please refer to the docs for usage. :)"]
    end

    # Gets the grouped events for a site_id
    get '/events/:site_id/?' do
      json Event.select('event_type, COUNT(*) AS incidents').where(:site_id => params[:site_id]).group('event_type')
    end

    # Receives an event and posts the stats. It expects a JSON payload with
    # the form {site_id: 1, event_type: "event", data: {...}}
    post '/events/?' do
      @event = MultiJson.decode(params[:event])
      json Metriclient.post_event(@event)
    end

    # Receives an error and posts the stats. It expects a JSON payload with
    # the form {error: "", line: "", url: ""}
    post '/errors/?' do
      @error = MultiJson.decode(params[:event])
      json Metriclient.post_error(@error)
    end
  end
end
