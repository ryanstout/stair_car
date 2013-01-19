module StairCar
  module UMatrixCompare
    # def >(val)
    #  map {|v| (v > val) ? 1 : 0 }
    # end
    #
    # def >=(val)
    #   map {|v| (v >= val) ? 1 : 0 }
    # end
    #
    # def <(val)
    #  map {|v| (v < val) ? 1 : 0 }
    # end
    #
    # def <=(val)
    #   map {|v| (v <= val) ? 1 : 0 }
    # end
    #
    # def find(matrix)
    #
    # end
    #
    # def any?
    #   @data.cardinality > 0
    # end

    # Compares this matrix to another to see if they are the same (in values)
    def ==(matrix2)
      if matrix2.is_a?(Fixnum) || matrix2.is_a?(Float)
        # See if its a 1x1
        if rows != 1 || cols != 1
          return false
        else
          # Check if the value matches
          return self.to_i == matrix2
        end
      else
        self.data.equalsContent(matrix2.data)
      end
    end

  end
end
