require 'sinatra/base'
require 'sinatra/reloader'
require 'awesome_print'
require 'psych'

module Metriclient
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    configure do
      enable :logging
      enable :raise_errors
    end

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

    get '/' do
      "Here be dragons."
    end

    get '/dragons/?' do
      "Told ya."
    end

    get '/errors/:id/?' do
      @error = Error.find_by_id(params[:id]) || ErrorArchive.find_by_id(params[:id])
      halt 404, "not found" unless @error
      erb :'errors/show'
    end

    get '/recent_errors/:id/?' do
      @error = Error.find_by_id(params[:id])
      halt 404, "not found" unless @error
      erb :'errors/show'
    end
  end
end
