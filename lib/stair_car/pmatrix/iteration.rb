module StairCar
  module PMatrixIteration
    def each(&block)
      rows.times do |row|
        cols.times do |col|
          yield(self[row,col])
        end
      end
    end

    def each_with_index(&block)
      rows.times do |row|
        cols.times do |col|
          yield(self[row,col], row, col)
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

    def each_column
      cols.times do |col_number|
        yield(self[nil,col_number],col_number)
      end
    end

    def each_row
      rows.times do |row_number|
        yield(self[row_number,nil],row_number)
      end
    end

  end
end