class FnordMetric::Gauge

  include FnordMetric::GaugeCalculations
  include FnordMetric::GaugeModifiers
  include FnordMetric::GaugeValidations
  include FnordMetric::GaugeRendering

  def initialize(opts)
    opts.fetch(:key) && opts.fetch(:key_prefix)
    @opts = opts
  end

  def tick_str
    _tick = tick
    if _tick == 1.day
      str = 'daily'
    elsif _tick == 1.week
      str = 'weekly'
    elsif _tick == 1.month
      str = 'monthly'
    else
      str = _tick.to_s
    end

    str
  end

  def tick
    (@opts[:tick] || @opts[:resolution] || 3600).to_i
  end

  def retention
    tick * 10 # FIXPAUL!
  end

  def i_tick_at(time, _tick=tick)
    t = Time.at(time)

    if _tick == 1.day
      Time.local(t.year, t.month, t.day).to_i
    elsif _tick == 1.week
      t.strftime('%W').to_i * 86400 * 7
    elsif _tick == 1.month
      Time.local(t.year, t.month).to_i
    else
      (time/_tick.to_f).floor*_tick
    end
  end

  def tick_at(time, _tick=tick)
    if _tick == 1.day
      tk = Time.at(time).strftime('%Y-%m-%d')
    elsif _tick == 1.week
      tk = Time.at(time).strftime('%Y#%W')
    elsif _tick == 1.month
      tk = Time.at(time).strftime('%Y-%m')
    else
      tk = (time/_tick.to_f).floor*_tick
    end
    tk
  end

  def name
    @opts[:key]
  end

  def title
    @opts[:title] || name
  end

  def group
    @opts[:group] || "Gauges"
  end

  def key_nouns
    @opts[:key_nouns] || ["Key", "Keys"]
  end

  def key(_append=nil)
    [@opts[:key_prefix], "gauge", name, tick_str, _append].flatten.compact.join("-")
  end

  def tick_key(_time, _append=nil)
    key([(progressive? ? :progressive : tick_at(_time).to_s), _append])
  end

  def tick_keys(_range, _append=nil)
    ticks_in(_range).map{ |_t| tick_key(_t, _append) }
  end

  def retention_key(_time, _append=nil)
    key([Time.at(_time).year.to_s, _append])
#    key([tick_at(_time, retention).to_s, _append])
  end

  def two_dimensional?
    !@opts[:three_dimensional]
  end

  def three_dimensional?
    !!@opts[:three_dimensional]
  end

  def progressive?
    !!@opts[:progressive]
  end

  def unique?
    !!@opts[:unique]
  end

  def average?
    !!@opts[:average]
  end

  def has_series?
    false
  end

  def redis
    @redis ||= EM::Hiredis.connect(FnordMetric.options[:redis_url]) # FIXPAUL
  end

  def sync_redis
    @sync_redis ||= FnordMetric.mk_redis # FIXPAUL
  end

  def error!(msg)
    FnordMetric.error(msg)
  end

end
