require File.dirname(__FILE__) + '/../pcolt/parallelcolt-0.9.4'
require 'stair_car/types'
require 'stair_car/inspect'
require 'stair_car/indicies'
require 'stair_car/iteration'
require 'stair_car/matrix_math'
require 'stair_car/transforms'
require 'stair_car/compare'


module StairCar
  class PMatrix
    include Types
    include Inspect
    include Indicies
    include Iteration
    include MatrixMath
    include Transforms
    include Compare

    class MatrixDimensionsError < RuntimeError
    end

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

    def from_array(array, klass)
      rows, cols = array_dimensions(array)

      @data = klass.new(rows, cols)
      self[nil,nil] = array
    end

    def setup_default_values(initialize_values)
      if initialize_values == :ones
        @data.assign(1.0)
      end
    end

    def [](rows, cols)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

      # Returns either the value in a cell or a subview
      if rows && cols && rows.size == 1 && cols.size == 1 && rows.first.is_a?(Fixnum) && cols.first.is_a?(Fixnum)
        @data.get(rows.first, cols.first)
      else
        # Get subview, also convert rows/cols to java arrays
        self.class.new(@data.view_selection(rows && rows.to_java(:int), cols && cols.to_java(:int)))
      end
    end

    def []=(rows, cols, value)
      rows = convert_indicies(rows, self.rows)
      cols = convert_indicies(cols, self.cols)

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

        value = convert_value(value)
        subview.assign(value)
      end
    end

    def array_dimensions(array)
      if array.first.is_a?(Array)
        # Nested array
        rows = array.size
        cols = array.first.size
      else
        # 1 dimensional array
        cols = array.size
        rows = 1
      end

      return rows, cols
    end

    def convert_value(value)
      if value.is_a?(Array)
        if value.first.is_a?(Array)
          # Convert the array of arrays to a java array of arrays that we can use
          klass = eval("Java::#{type}[]")
        else
          # Convert to an array of the type
          klass = type
        end
        return value.to_java(klass)
      else
        return value
      end
    end

    def dup
      PMatrix.new(@data.copy)
    end

    def self.init_method_names
      [true, false].each do |sparse|
        [:double, :float].each do |type|
          [:zeros, :ones, :rand, :desc, :asc].each do |initialize_values|
            method_name = :"#{sparse ? 'sp' : ''}#{initialize_values}#{type == :float ? 'f' : ''}"

            yield(method_name, sparse, type, initialize_values)
          end
        end
      end

      # Also add float and double shortcuts
      yield(:float, false, :float, :zeros)
      yield(:double, false, :float, :zeros)
    end

    init_method_names do |method_name, sparse, type, initialize_values|
      define_singleton_method(method_name) do |cols, rows|
        new(cols, rows, type, sparse, initialize_values)
      end
    end
  end
end