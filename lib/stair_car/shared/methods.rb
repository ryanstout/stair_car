module StairCar
  module Methods
    def abs
      self.map {|v| v.abs }
    end

    def sqrt
      self.map {|v| Math.sqrt(v) }
    end
  end
end