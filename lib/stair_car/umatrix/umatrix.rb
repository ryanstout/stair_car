require File.dirname(__FILE__) + '/../../pcolt/parallelcolt-0.9.4'
require File.dirname(__FILE__) + '/../../ujmp/ujmp-complete-0.2.5'

require 'stair_car/umatrix/types'
require 'stair_car/umatrix/matrix_math'
require 'stair_car/umatrix/transforms'
require 'stair_car/umatrix/compare'
require 'stair_car/shared/iteration'
require 'stair_car/shared/inspect'
require 'stair_car/shared/indicies'
require 'stair_car/shared/init_methods'
require 'stair_car/shared/errors'
require 'stair_car/shared/methods'

module StairCar
  class UMatrix
    include UMatrixTypes
    # include Indicies
    include UMatrixMatrixMath
    include UMatrixTransforms
    include UMatrixCompare
    include Iteration
    include Inspect
    include Indicies
    include InitMethods
    include Methods

    attr_accessor :data

    def initialize(rows_or_data=nil, cols=nil, type=:double, sparse=false, initialize_values=:zeros)
      if rows_or_data.is_a?(Array)
        klass = type_class(type, sparse, initialize_values)

        # Create the matrix from an array
        from_array(rows_or_data, klass)
      elsif rows_or_data.is_a?(Fixnum)
        raise MatrixDimensionsError, "Must specify columns and rows" unless rows_or_data && cols
        klass = type_class(type, sparse, initialize_values)
        if klass.is_a?(Method) || klass.is_a?(Proc)
          # A factory method was returned, call to build
          @data = klass.call(rows_or_data, cols)
        else
          # A class was returned, create new
          @data = klass.new(rows_or_data, cols)
        end

        setup_default_values(initialize_values)
      else
        # Passing in data directly
        @data = rows_or_data
      end
    end

    def setup_default_values(initialize_values)
      if initialize_values == :asc
        i = 0
        self.map! do |val,row,col|
          self[row,col] = i
          i += 1
        end
      elsif initialize_values == :desc
        i = size
        self.map! do |val,row,col|
          self[row,col] = i
          i -= 1
        end
      end
    end


    def shape
      rows, cols = data.size

      return [rows, cols]
    end

    def size
      rows, cols = shape
      return rows * cols
    end

    def rows
      return shape[0]
    end

    def cols
      return shape[1]
    end

    # Takes a 1x1 matrix and converts it to an integer, raises an exception
    # if the matrix is not 1x1
    def to_i
      if rows != 1 || cols != 1
        raise IncorrectMatrixDimensions, "to_i should only be called on 1x1 matricies"
      end
      return value_at(0, 0)
    end

    # Gets the value at the row and column
    def value_at(row, col)
      row = convert_indicies(row, self.rows)
      col = convert_indicies(col, self.cols)

      # Returns either the value in a cell or a subview
      # From jruby we have to call this way for doubles
      if @data.is_a?(Java::org.ujmp.core.objectmatrix.impl.ObjectCalculationMatrix)
        @data.getObject(row.first.to_java(:int), col.first.to_java(:int)) || 0.0
      else
        # From jruby we have to call this way for doubles
        @data.java_send(:getObject, [Java::long, Java::long], row.first, col.first) || 0.0
      end
    end

    def [](rows, cols)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

      # Get subview, also convert rows/cols to java arrays
      if !rows && !cols
        return self.class.new(@data)
      else
        if rows
          return self.class.new(@data.select(Java::OrgUjmpCoreCalculation::Calculation.LINK, rows, cols))
        else
          # If row is nil, we need to lookup by columns directly
          return self.class.new(@data.select_columns(Java::OrgUjmpCoreCalculation::Calculation.LINK, cols))
        end
      end
    end

    def []=(rows, cols, value)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

      # Set either the value in a cell or a subview with a matrix
      if rows && cols && rows.size == 1 && cols.size == 1 && rows.first.is_a?(Fixnum) && cols.first.is_a?(Fixnum)
        @data.setObject(value.to_java(:double), rows.first, cols.first)
      else
        subview = self[rows, cols]

        # Assign a single array or a nested array
        if value.is_a?(Array)
          value_rows, value_cols = array_dimensions(value)

          # If one dimentional, and they want to set cols
          if value_rows == 1 && subview.cols == 1
            # Transpose so we can place an array vertically
            subview = subview.transpose
          end

          # Check to make sure the sizes match
          if value_rows != subview.rows || value_cols != subview.cols
            raise MatrixDimensionsError, "the array you are trying to assign is not the correct size"
          end
        end

        # value = convert_value(value)
        unless value[0].is_a?(Array)
          value = [value]
        end

        value.each_with_index do |row,row_index|
          row.each_with_index do |cell,col_index|
            subview[row_index, col_index] = cell
          end
        end
      end
    end

    # Loop through each non-zero value, pass in the value, row, column
    def each_non_zero(&block)
      @data.available_coordinates.each do |row, col|
        val = self.value_at(row,col)
        yield(val, row, col)
      end
    end

    def dup
      UMatrix.new(@data.clone)
    end
  end
end