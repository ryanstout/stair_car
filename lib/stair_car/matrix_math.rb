module StairCar
  module MatrixMath
    class MatrixMathError < RuntimeError
    end

    def perform(val, &block)
      result = @data.copy
      if val.is_a?(PMatrix)
        if rows == val.rows && cols == val.cols
          # Another matrix of the same size
          result = result.assign(val.data, &block)
        elsif rows == val.rows && val.cols == 1
          # Vector on column (vertical)
          PMatrix.new(result).each_column do |row|
            row.data.assign(val.data, &block)
          end
        elsif cols == val.cols && val.rows == 1
          # Vector on rows (horizontal)
          PMatrix.new(result).each_row do |col|
            col.data.assign(val.data, &block)
          end
        else
          # Incorrect size
          raise MatrixMathError, "matrix dimensions incorrect"
        end
      else
        # Passed in a number
        perform_on_val = Proc.new do |cell_value|
          yield(cell_value, val)
        end

        result.assign(perform_on_val)
      end

      return PMatrix.new(result)
    end

    def +(val)
      perform(val) { |a,b| a + b }
      # perform(val, Java::cern.jet.math.tdouble.DoubleFunctions.plus)
    end

    def -(val)
      perform(val) { |a,b| a - b }
    end

    def **(val)
      perform(val) { |a,b| a * b }
    end

    def /(val)
      perform(val) { |a,b| a / b }
    end

    def *(val)
      n = self.rows
      m = self.cols

      p = val.rows
      q = val.cols

      if m != p
        raise MatrixMathError, "matricies can not be multiplied"
      end

      # Build a like matrix to receive
      c = @data.like(n, q)

      @data.z_mult(val.data, c)

      return PMatrix.new(c)
    end

    def sum(dimension=nil)
      if dimension == 0
        # Sum rows
        return PMatrix.ones(1, rows) * self
      elsif dimension == 1
        # Sum cols
        return self * PMatrix.ones(cols, 1)
      else
        return @data.z_sum
      end
    end

    def max(dimension=nil)
      if dimension
        value = aggrate_on_dimension(:max, dimension)
      else
        value, row, col = @data.max_location
      end

      return value
    end

    def min(dimension=nil)
      if dimension
        value = aggrate_on_dimension(:min, dimension)
      else
        value, row, col = @data.min_location
      end

      return value
    end

    def mean(dimension=nil)
      if dimension
        value = aggrate_on_dimension(:mean, dimension)
      else
        value = self.sum / self.size
      end

      return value
    end

    def variance(dimension=nil, sample=false)
      if dimension
        value = aggrate_on_dimension(:variance, dimension, sample)
      else
        mean = self.mean
        total = 0
        self.each_non_zero do |v|
          total += (mean - v) ** 2
        end

        if sample
          value = total / (self.size - 1)
        else
          value = total / self.size
        end
      end

      return value
    end

    def std(dimension=nil, sample=false)
      if dimension
        value = aggrate_on_dimension(:variance, dimension, sample)
      else
        value = Math.sqrt(self.variance(dimension, sample))
      end

      return value
    end

    private
      def aggrate_on_dimension(method_name, dimension, *args)
        if dimension == 0
          # Get the per row
          vals = PMatrix.new(@data.like(rows, 1))

          self.each_row do |row, row_number|
            vals[row_number,0] = row.send(method_name, nil, *args).to_f
          end

          return vals
        elsif dimension == 1
          # Get the per row
          vals = PMatrix.new(@data.like(1, cols))

          self.each_column do |col, col_number|
            vals[0,col_number] = col.send(method_name, nil, *args).to_f
          end

          return vals
        end
      end
  end
end