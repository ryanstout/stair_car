module StairCar
  module PMatrixTransforms
    def transpose
      return PMatrix.new(@data.view_dice.copy)
    end

    def ~
      return transpose
    end

    def inv
      algebra = Java::cern.colt.matrix.tdouble.algo.DenseDoubleAlgebra.new
      begin
        return PMatrix.new(algebra.inverse(@data))
      rescue Java::JavaLang::IllegalArgumentException => e
        if e.message == 'Matrix is singular.' || e.message == 'A is singular.'
          raise InverseMatrixIsSignular, e.message
        else
          raise
        end
      end
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
      result = @data.for_each_non_zero do |row,col,val|
        yield(val, row, col)
      end

      PMatrix.new(result)
    end

    def count
      count = 0

      each do |val,row,col|
        if yield(val,row,col)
          count += 1
        end
      end

      return count
    end

    # Converts the matrix into an array
    def to_a
      array = []
      rows.times do |row|
        col_array = []
        cols.times do |col|
          col_array << self.value_at(row,col)
        end
        array << col_array
      end

      return array
    end
  end
end