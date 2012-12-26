module StairCar
  module UMatrixMatrixMath
    class MatrixMathError < RuntimeError
    end

    # In jruby, we need to pass the params to java_methods to distinguish them
    # when multiple java methods (with different params) have the same name.
    def find_params(object, method_name, &search)
      while object
        object.declared_instance_methods.each do |method|
          if method.name == method_name
            if yield(method.parameter_types)
              # Method checks to see if the parameter types are correct, if they
              # are then we return them.
              return method.parameter_types
            end
          end
        end

        # If we didn't find it here, move up the chain
        object = object.superclass
      end

      return nil
    end

    def perform(method, val)
      method = method.to_s
      result = @data.clone
      if val.is_a?(UMatrix)
        @param_types ||= {}
        @param_types[method] ||= find_params(result.java_class, method) do |params|
          # params.first.name == 'org.ujmp.core.Matrix'
          params.size == 3 &&
          params[0].name == 'org.ujmp.core.calculation.Calculation$Ret' &&
          params[1].name == 'boolean' &&
          params[2].name == 'org.ujmp.core.Matrix'
        end
        if rows == val.rows && cols == val.cols
          # Another matrix of the same size
          # result = result.java_send(method, @param_types[method], val.data)
          result.java_send(method, @param_types[method], Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.data)
        elsif rows == val.rows && val.cols == 1
          # Vector on column (vertical)
          UMatrix.new(result).each_column do |row|
            # row.data.send(method, Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.data)
            # row.data.java_send(method, @param_types[method], val.data)
            row.data.java_send(method, @param_types[method], Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.data)
          end
        elsif cols == val.cols && val.rows == 1
          # Vector on rows (horizontal)
          UMatrix.new(result).each_row do |col|
            col.data.java_send(method, @param_types[method], Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.data)
            # col.data.send(method, Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.data)
          end
        else
          # Incorrect size
          raise MatrixMathError, "matrix dimensions incorrect"
        end
      else
        # Passed in a number
        result = result.send(method, Java::OrgUjmpCoreCalculation::Calculation.ORIG, false.to_java, val.to_java(:double))
      end

      return UMatrix.new(result)
    end

    def +(val)
      perform(:plus, val)
    end

    def -(val)
      perform(:minus, val)
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

      return UMatrix.new(c)
    end

    # ujmp requires you pass in a special code for all dimensions
    def dim_convert(dimension)
      if dimension == nil
        dimension = Java::org.ujmp.core.Matrix::ALL
      end

      return dimension
    end

    # Calls aggraration method on the data
    def call_data_method(method, dimension, *args)
      result = UMatrix.new(@data.send(method, Java::OrgUjmpCoreCalculation::Calculation.NEW, dim_convert(dimension), *args))
      if dimension
        return result
      else
        # Just return the first element
        return result[0,0]
      end
    end

    def sum(dimension=nil)
      return call_data_method(:sum, dimension, false)
    end

    def max(dimension=nil)
      return call_data_method(:max, dimension)
    end

    def min(dimension=nil)
      return call_data_method(:min, dimension)
    end

    def mean(dimension=nil)
      return call_data_method(:mean, dimension, false)
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
          vals = UMatrix.new(@data.like(rows, 1))

          self.each_row do |row, row_number|
            vals[row_number,0] = row.send(method_name, nil, *args).to_f
          end

          return vals
        elsif dimension == 1
          # Get the per row
          vals = UMatrix.new(@data.like(1, cols))

          self.each_column do |col, col_number|
            vals[0,col_number] = col.send(method_name, nil, *args).to_f
          end

          return vals
        end
      end
  end
end