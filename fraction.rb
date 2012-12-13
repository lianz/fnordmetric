$: << ::File.expand_path("../lib/", __FILE__)
require "fnordmetric"

FnordMetric.namespace :fn do
  hide_overview
  hide_active_users


  timeseries_gauge :number_of_signups,
    :group => "My Group",
    :title => "Number of Signups",
    :key_nouns => ["Singup", "Signups"],
    :series => [:via_facebook],
    :resolution => 1.day,
    :include_current => true,
    :width => 80

  event :signup do
    if rand(10) >= 7
      incr_numerator :number_of_signups, :via_facebook, 1
    end
    incr_denominator :number_of_signups, :via_facebook, 1
  end

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
    api.event(:_type => :signup)
    sleep rand(10)/100.to_f
  end
end

FnordMetric.standalone
