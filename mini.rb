$: << ::File.expand_path("../lib/", __FILE__)
require "fnordmetric"

FnordMetric.namespace :fn do
  hide_overview
  hide_active_users


  gauge :events_per_day,    :tick => 1.day
  gauge :events_per_hour,   :tick => 1.hour
  gauge :events_per_second, :tick => 1.second
  gauge :events_per_minute, :tick => 1.minute


  event :"*" do
    incr :events_per_day
    incr :events_per_hour
    incr :events_per_minute
    incr :events_per_second
  end

  gauge :unicorn_seen, :tick => 1.minute

  event :unicorn_seen do
    incr :unicorn_seen
  end

  widget :unicorn_seen, {
    :title => ":unicorn_seen",
    :type => :timeline,
    :width => 100,
    :gauges => :unicorn_seen,
    :include_current => true,
    :autoupdate => 30,
  }

#
#  widget 'TechStats', {
#    :title => "Events per Hour",
#    :type => :timeline,
#    :width => 50,
#    :gauges => :events_per_hour,
#    :include_current => true,
#    :autoupdate => 30
#  }
#
#  widget 'TechStats', {
#    :title => "Events per Minute",
#    :type => :timeline,
#    :width => 50,
#    :gauges => :events_per_minute,
#    :include_current => true,
#    :autoupdate => 30
#  }
#
#
#  widget 'TechStats', {
#    :title => "Events/Second",
#    :type => :timeline,
#    :width => 50,
#    :gauges => :events_per_second,
#    :include_current => true,
#    :plot_style => :areaspline,
#    :autoupdate => 1
#  }
#
#  widget 'TechStats', {
#    :title => "Events Numbers",
#    :type => :numbers,
#    :width => 100,
#    :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
#    :offsets => [1,3,5,10],
#    :autoupdate => 1
#  }

end

FnordMetric.options = {
  :event_queue_ttl  => 100, # all data that isn't processed within 10s is discarded to prevent memory overruns
  :event_data_ttl   => 1, # event data is stored for one hour (needed for the active users view)
  :session_data_ttl => 1, # session data is stored for one hour (needed for the active users view)
  :redis_prefix => "fnordmetric"
}

Thread.new do
  api = FnordMetric::API.new
  loop do
    api.event(:_type => :unicorn_seen)
    sleep rand(10)/100.to_f
  end
end

FnordMetric.standalone
