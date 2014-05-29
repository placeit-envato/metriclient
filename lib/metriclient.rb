# Get the current path to include files
$:.unshift File.expand_path(File.dirname(__FILE__))
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'database_manager/database_manager'
require 'active_record_overrides'
require 'models/event_data'
require 'models/event'
require 'models/error'
require 'models/error_archive'

module Metriclient

  # Post a new event to the stats
  # Expects the event hash to be of the following form:
  # {"site_id": Integer, "data": Hash, "event_type": String}
  #
  # Will return either true if it was posted or false if it wasn't
  def self.post_event (event_hash)

    meta_data = event_hash.delete('data')

    event = Event.create(event_hash)

    if event.event_type == "Breezi:track:finish"
      self.update_time(event.site_id, meta_data["timeTotal"])
    end

    # Store the event meta.
    if meta_data
      meta_data.each do |k,v|
        event.event_meta.create({'key' => k, 'value' => v, 'site_id' => event.site_id})
      end
    end

    ["OK"]
  end

  def self.update_time (site_id, time)
    event = Event.find_or_create_by_site_id_and_event_type(site_id, "Breezi:track:total")
    meta = event.event_meta.find_or_initialize_by_key("totalTime")
    meta.value = meta.value.to_i + time.to_i
    meta.save
  end

  def self.post_error (error_hash)
    Error.create(error_hash)
    ["OK"]
  end
end
