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
      self.data.equalsContent(matrix2.data)
    end

  end
end
