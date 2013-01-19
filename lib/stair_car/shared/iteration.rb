module StairCar
  module Iteration
    def each(&block)
      rows.times do |row|
        cols.times do |col|
          yield(self.value_at(row,col))
        end
      end
    end

    def each_with_index(&block)
      rows.times do |row|
        cols.times do |col|
          yield(self.value_at(row,col), row, col)
        end
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