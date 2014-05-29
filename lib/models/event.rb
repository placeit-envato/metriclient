class Event < ActiveRecord::Base
  has_many :event_meta, :class_name => ::EventMeta
end
