require File.dirname(__FILE__) + '/../../ujmp/ujmp-complete-0.2.5'

require 'stair_car/umatrix/types'
# require 'stair_car/inspect'
# require 'stair_car/indicies'
# require 'stair_car/iteration'
# require 'stair_car/matrix_math'
# require 'stair_car/transforms'
# require 'stair_car/compare'

module StairCar
  class UMatrix
    include UMatrix::Types
    # include Inspect
    # include Indicies
    # include Iteration
    # include MatrixMath
    # include Transforms
    # include Compare

    attr_accessor :data

    def initialize(rows_or_data=nil, cols=nil, type=:double, sparse=false, initialize_values=:zeros)
      if rows_or_data.is_a?(Array)
        klass = type_class(type, sparse, initialize_values)

        # Create the matrix from an array
        from_array(rows_or_data, klass)
      elsif rows_or_data.is_a?(Fixnum)
        raise MatrixDimensionsError, "Must specify columns and rows" unless rows_or_data && cols
        klass = type_class(type, sparse, initialize_values)
        if klass.is_a?(Method)
          # A factory method was returned, call to build
          @data = klass.call(rows_or_data, cols)
        else
          # A class was returned, create new
          @data = klass.new(rows_or_data, cols)

          setup_default_values(initialize_values)
        end
      else
        # Passing in data directly
        @data = rows_or_data
      end
    end

    def inspect
      @data.inspect
    end

    def [](rows, cols)
      @data.getDouble(rows, cols)

    end
  end
end