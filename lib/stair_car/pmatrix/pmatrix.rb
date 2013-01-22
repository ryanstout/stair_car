require File.dirname(__FILE__) + '/../../pcolt/parallelcolt-0.9.4'
require 'stair_car/pmatrix/types'
require 'stair_car/pmatrix/matrix_math'
require 'stair_car/pmatrix/transforms'
require 'stair_car/pmatrix/compare'
require 'stair_car/shared/iteration'
require 'stair_car/shared/inspect'
require 'stair_car/shared/indicies'
require 'stair_car/shared/init_methods'
require 'stair_car/shared/errors'
require 'stair_car/shared/methods'


module StairCar
  class PMatrix
    include PMatrixTypes
    include PMatrixMatrixMath
    include PMatrixTransforms
    include PMatrixCompare
    include Iteration
    include Inspect
    include Indicies
    include InitMethods
    include Methods

    attr_accessor :data

    # Proxy methods
    [:size, :rows].each do |method_name|
      define_method(method_name) do |*args|
        @data.send(method_name, *args)
      end
    end

    def cols
      @data.columns
    end

    def shape
      [rows, cols]
    end


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

          setup_default_values(initialize_values)
        end
      else
        # Passing in data directly
        @data = rows_or_data
      end
    end

    def setup_default_values(initialize_values)
      if initialize_values == :ones
        @data.assign(1.0)
      end
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
      return @data.get(row.first, col.first)
    end

    def [](rows, cols)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

      # Returns either the value in a cell or a subview
      # if rows && cols && rows.size == 1 && cols.size == 1 && rows.first.is_a?(Fixnum) && cols.first.is_a?(Fixnum)
      #   @data.get(rows.first, cols.first)
      # else
        # Get subview, also convert rows/cols to java arrays
        self.class.new(@data.view_selection(rows && rows.to_java(:int), cols && cols.to_java(:int)))
      # end
    end

    def []=(rows, cols, value)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

      if value.is_a?(PMatrix) && value.rows == 1 && value.cols == 1
        value = value.value_at(0,0)
      end

      # Set either the value in a cell or a subview with a matrix
      if rows && cols && rows.size == 1 && cols.size == 1 && rows.first.is_a?(Fixnum) && cols.first.is_a?(Fixnum)
        @data.set(rows.first, cols.first, value)
      else
        subview = @data.view_selection(rows && rows.to_java(:int), cols && cols.to_java(:int))

        # Assign a single array or a nested array
        if value.is_a?(Array)
          value_rows, value_cols = array_dimensions(value)

          # If one dimentional, and they want to set cols
          if value_rows == 1 && subview.columns == 1
            # Transpose so we can place an array vertically
            subview = subview.view_dice
          end

          # Check to make sure the sizes match
          if value_rows != subview.rows || value_cols != subview.columns
            raise MatrixDimensionsError, "the array you are trying to assign is not the correct size"
          end
        end

        if value.is_a?(PMatrix)
          value = value.data
        end

        if value.is_a?(Array)
          assign_values(subview, value)
        else
          subview.assign(value)
        end
      end
    end


    # Loop through each non-zero value, pass in the value, row, column
    def each_non_zero(&block)
      @data.for_each_non_zero do |row, col, value|
        yield(value, row, col)

        value
      end
    end


    # Takes an array and assigns it to the right cells in the subview
    def assign_values(subview, value)
      unless value.first.is_a?(Array)
        value = [value]
      end

      value.each_with_index do |row,row_index|
        row.each_with_index do |val,col_index|
          subview.set(row_index, col_index, val.to_java(:double))
        end
      end
    end

    def dup
      PMatrix.new(@data.copy)
    end
  end
end