module StairCar
  module Transforms
    def transpose
      return PMatrix.new(@data.view_dice.copy)
    end

    def ~
      return transpose
    end

    def map(&block)
      PMatrix.new(@data.copy).map!(&block)
    end

    def map!
      result = self.each_with_index do |val,row,col|
        self[row,col] = yield(val, row, col)
      end

      return self
    end

    def map_non_zero(&block)
      PMatrix.new(@data.copy).map_non_zero!(&block)
    end

    def map_non_zero!
      result = @data.for_each_non_zero do |row,col,val|
        yield(val, row, col)
      end

      PMatrix.new(result)
    end

    # Converts the matrix into an array
    def to_a
      array = []
      rows.times do |row|
        col_array = []
        cols.times do |col|
          col_array << self[row,col]
        end
        array << col_array
      end

      return array
    end
  end
end