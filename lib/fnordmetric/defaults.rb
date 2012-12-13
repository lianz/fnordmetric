FnordMetric::COLORS = ["#4572a7", "#aa4643", "#89a54e", "#80699b", "#3d96ae", "#db843d"].reverse

FnordMetric::TICKS = lambda{ |tick, span| [tick, 60, 300, 1200, 3600, 86400]
  .select{ |t| (t >= tick) && ((span/t) >= 1) }
  .uniq }


FnordMetric::DEFAULT_PROC = lambda{ |arg| }

class String
  def is_numeric?
    self.match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) == nil ? false : true
  end
end
