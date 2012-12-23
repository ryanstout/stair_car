module StairCar
  module UMatrixMatrixMath
    class MatrixMathError < RuntimeError
    end

    def perform(val, &block)
      result = @data.clone
      if val.is_a?(PMatrix)
        if rows == val.rows && cols == val.cols
          # Another matrix of the same size
          result = yield(result, val)
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
    end

    def -(val)
    end

    def **(val)
    end

    def /(val)
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

    # ujmp requires you pass in a special code for all dimensions
    def dim_convert(dimension)
      if dimension == nil
        dimension = Java::org.ujmp.core.Matrix::ALL
      end

      return dimension
    end

    # Calls aggraration method on the data
    def call_data_method(method, dimension)
      UMatrix.new(@data.send(method, Java::OrgUjmpCoreCalculation::Calculation.NEW, dim_convert(dimension), false))
    end

    def sum(dimension=nil)
      return call_data_method(:sum, dimension)
    end

    def max(dimension=nil)
      return call_data_method(:max, dimension)
    end

    def min(dimension=nil)
      return call_data_method(:min, dimension)
    end

    def mean(dimension=nil)
      return call_data_method(:mean, dimension)
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