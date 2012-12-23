module StairCar
  module UMatrixTransforms
    def transpose
      return UMatrix.new(@data.transpose)
    end

    def ~
      return transpose
    end

    def map(&block)
      dup.map!(&block)
    end

    def map!
      result = self.each_with_index do |val,row,col|
        self[row,col] = yield(val, row, col)
      end

      return self
    end

    def map_non_zero(&block)
      dup.map_non_zero!(&block)
    end

    def map_non_zero!
      each_non_zero do |val,row,col|
        self[row,col] = yield(val, row, col)
      end

      return self
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